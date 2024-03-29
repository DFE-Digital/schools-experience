class Bookings::School < ApplicationRecord
  resourcify

  self.ignored_columns += %w[dfe_signin_organisation_uuid]
  include FullTextSearch
  include GeographicSearch

  EXPERIENCE_TYPES = %w[virtual inschool both].freeze

  before_validation :nilify_availability_info

  validates :name,
    presence: true,
    length: { maximum: 128 }

  validates :fee,
    presence: true,
    numericality: { greater_than_or_equal_to: 0, only_integer: true }

  validates :website, allow_nil: true, website: true

  validates :teacher_training_website, allow_nil: true, website: true

  validates :contact_email,
    allow_nil: true,
    format: {
      with: URI::MailTo::EMAIL_REGEXP,
      message: "isn't a valid email address"
    }

  validates :availability_info,
    presence: true,
    length: { minimum: 3 },
    on: :configuring_availability

  validates :experience_type,
    inclusion: EXPERIENCE_TYPES,
    on: :configuring_availability

  validates :availability_preference_fixed,
    inclusion: { in: [true, false] },
    on: :selecting_availability_preference

  has_many :bookings_schools_subjects,
    class_name: "Bookings::SchoolsSubject",
    inverse_of: :bookings_school,
    foreign_key: :bookings_school_id,
    dependent: :destroy

  has_many :subjects,
    class_name: "Bookings::Subject",
    through: :bookings_schools_subjects,
    source: :bookings_subject

  has_many :bookings_schools_phases,
    class_name: "Bookings::SchoolsPhase",
    inverse_of: :bookings_school,
    foreign_key: :bookings_school_id,
    dependent: :destroy

  has_many :phases,
    class_name: "Bookings::Phase",
    through: :bookings_schools_phases,
    source: :bookings_phase

  belongs_to :school_type,
    class_name: "Bookings::SchoolType",
    inverse_of: :schools,
    foreign_key: :bookings_school_type_id

  has_one :school_profile,
    class_name: "Schools::SchoolProfile",
    inverse_of: :bookings_school,
    foreign_key: :bookings_school_id,
    dependent: :destroy

  has_one :profile,
    class_name: "Bookings::Profile",
    foreign_key: :school_id,
    inverse_of: :school,
    dependent: :destroy

  has_many :bookings_placement_dates,
    class_name: 'Bookings::PlacementDate',
    foreign_key: :bookings_school_id,
    inverse_of: :bookings_school,
    dependent: :destroy

  has_many :available_placement_dates,
    -> { available },
    class_name: 'Bookings::PlacementDate',
    foreign_key: :bookings_school_id

  has_many :bookings,
    class_name: 'Bookings::Booking',
    foreign_key: :bookings_school_id,
    inverse_of: :bookings_school,
    dependent: :destroy

  has_many :placement_requests,
    class_name: 'Bookings::PlacementRequest',
    foreign_key: :bookings_school_id,
    inverse_of: :school,
    dependent: :destroy

  has_many :events,
    foreign_key: :bookings_school_id,
    inverse_of: :bookings_school,
    dependent: :destroy

  scope :enabled, -> { where(enabled: true) }
  scope :ordered_by_name, -> { order(name: 'asc') }

  scope :that_provide, lambda { |subject_ids|
    if subject_ids.present?
      left_outer_joins(:bookings_schools_subjects)
        .where(bookings_schools_subjects: { bookings_subject_id: subject_ids })
    else
      all
    end
  }

  scope :at_phases, lambda { |phase_ids|
    if phase_ids.present?
      left_outer_joins(:bookings_schools_phases)
        .where(bookings_schools_phases: { bookings_phase_id: phase_ids })
    else
      all
    end
  }

  scope :costing_upto, lambda { |limit|
    if limit.present?
      where(arel_table[:fee].lteq(limit))
    else
      all
    end
  }

  scope :flexible, -> { where(availability_preference_fixed: false) }

  scope :flexible_with_description, -> { flexible.where.not(availability_info: nil) }

  scope :fixed, -> { where(availability_preference_fixed: true) }

  scope :fixed_with_available_dates, lambda {
    fixed.where(
      id: Bookings::School
        .default_scoped
        .joins(:available_placement_dates)
        .except(:select)
        .select(:id)
    )
  }

  scope :with_availability, -> { flexible_with_description.or(fixed_with_available_dates) }

  scope :without_availability, lambda {
    flexible.where(availability_info: nil).or(
      fixed.where.not(
        id: Bookings::School
          .default_scoped
          .joins(:available_placement_dates)
          .except(:select)
          .select(:id)
      )
    )
  }

  scope :with_dbs_policies, lambda { |policies|
    if policies.present?
      joins(:profile).where('bookings_profiles.dbs_policy_conditions IN (?)', policies)
    end
  }

  scope :disability_confident, lambda { |option|
    if option.present?
      joins(:profile)
        .where('bookings_profiles.disability_confident IS ?', option)
    else
      all
    end
  }

  scope :with_parking, lambda { |option|
    if option.present?
      joins(:profile)
        .where('bookings_profiles.parking_provided IS ?', option)
    else
      all
    end
  }

  scope :onboarded, -> { joins(:profile) }

  def to_param
    urn.to_s.presence
  end

  def onboarded?
    profile.present?
  end

  def disabled?
    !enabled?
  end

  def has_availability?
    has_available_flex_dates? || has_available_fix_dates?
  end

  def notification_emails
    if profile && profile.admin_contact_email.present?
      [profile.admin_contact_email, profile.admin_contact_email_secondary].compact
    else
      [contact_email]
    end
  end

  def admin_contact_phone
    profile&.admin_contact_phone
  end

  def disable!
    return true if disabled?

    Bookings::School.transaction do
      update!(enabled: false)

      Event.create!(event_type: 'school_disabled', bookings_school: self)
    end
  end

  def enable!
    return true if enabled?

    Bookings::School.transaction do
      update!(enabled: true)

      Event.create!(event_type: 'school_enabled', bookings_school: self)
    end
  end

  def has_secondary_phase?
    phases.any?(&:supports_subjects?)
  end

  def has_primary_phase?
    phases.any? { |p| !p.supports_subjects? }
  end

  def has_primary_and_secondary_phases?
    has_primary_phase? && has_secondary_phase?
  end

  def has_inschool_placements?
    if availability_preference_fixed?
      available_placement_dates.any?(&:inschool?)
    else
      experience_type != 'virtual'
    end
  end

  def has_virtual_placements?
    if availability_preference_fixed?
      available_placement_dates.any?(&:virtual?)
    else
      experience_type != 'inschool'
    end
  end

private

  def has_available_fix_dates?
    bookings_placement_dates.available.any?
  end

  def has_available_flex_dates?
    !availability_preference_fixed?
  end

  def nilify_availability_info
    self.availability_info = nil if availability_info == ''
  end
end
