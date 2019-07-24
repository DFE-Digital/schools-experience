class Bookings::School < ApplicationRecord
  include FullTextSearch
  include GeographicSearch

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
    allow_nil: true,
    length: { minimum: 3 }

  has_many :bookings_schools_subjects,
    class_name: "Bookings::SchoolsSubject",
    inverse_of: :bookings_school,
    foreign_key: :bookings_school_id

  has_many :subjects,
    class_name: "Bookings::Subject",
    through: :bookings_schools_subjects,
    source: :bookings_subject

  has_many :bookings_schools_phases,
    class_name: "Bookings::SchoolsPhase",
    inverse_of: :bookings_school,
    foreign_key: :bookings_school_id

  has_many :phases,
    class_name: "Bookings::Phase",
    through: :bookings_schools_phases,
    source: :bookings_phase

  belongs_to :school_type,
    class_name: "Bookings::SchoolType",
    foreign_key: :bookings_school_type_id

  has_one :school_profile,
    class_name: "Schools::SchoolProfile",
    foreign_key: :bookings_school_id,
    dependent: :destroy

  has_one :profile,
    class_name: "Bookings::Profile",
    foreign_key: :school_id,
    dependent: :destroy

  has_many :bookings_placement_dates,
    class_name: 'Bookings::PlacementDate',
    foreign_key: :bookings_school_id,
    dependent: :destroy

  has_many :bookings_placement_requests,
    class_name: 'Bookings::PlacementRequest',
    foreign_key: :bookings_school_id,
    dependent: :destroy

  has_many :bookings,
    class_name: 'Bookings::Booking',
    foreign_key: :bookings_school_id,
    dependent: :destroy

  has_many :placement_requests,
    class_name: 'Bookings::PlacementRequest',
    foreign_key: :bookings_school_id,
    dependent: :destroy

  has_many :events,
    foreign_key: :bookings_school_id,
    dependent: :destroy

  scope :enabled, -> { where(enabled: true) }

  scope :that_provide, ->(subject_ids) do
    if subject_ids.present?
      left_outer_joins(:bookings_schools_subjects)
        .where(bookings_schools_subjects: { bookings_subject_id: subject_ids })
    else
      all
    end
  end

  scope :at_phases, ->(phase_ids) do
    if phase_ids.present?
      left_outer_joins(:bookings_schools_phases)
        .where(bookings_schools_phases: { bookings_phase_id: phase_ids })
    else
      all
    end
  end

  scope :costing_upto, ->(limit) do
    if limit.present?
      where(arel_table[:fee].lteq(limit))
    else
      all
    end
  end

  scope :flexible, -> { where(availability_preference_fixed: false) }

  scope :flexible_with_description, -> { flexible.where.not(availability_info: nil) }

  scope :fixed, -> { where(availability_preference_fixed: true) }

  scope :fixed_with_available_dates, -> {
    fixed.where(
      id: Bookings::School
        .joins(:bookings_placement_dates)
        .merge(Bookings::PlacementDate.available)
        .except(:select)
        .select(:id)
    )
  }

  scope :with_availability, -> { flexible_with_description.or(fixed_with_available_dates) }

  def to_param
    urn.to_s.presence
  end

  def private_beta?
    profile.present?
  end

  def disabled?
    !enabled?
  end

  def has_availability?
    !availability_preference_fixed? || has_available_dates?
  end

  def notifications_email
    if profile && profile.admin_contact_email.present?
      profile.admin_contact_email
    else
      contact_email
    end
  end

  def admin_contact_name
    profile ? profile.admin_contact_full_name : contact_email
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

private

  def has_available_dates?
    bookings_placement_dates.available.any?
  end

  def nilify_availability_info
    self.availability_info = nil if availability_info == ''
  end
end
