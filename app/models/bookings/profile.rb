class Bookings::Profile < ApplicationRecord
  AVAILABLE_INTERVALS = %w(Daily One-off).freeze
  EMAIL_FORMAT = /\A.*@.*\..*\z/.freeze

  FIELDS_TO_NILIFY = %i{teacher_training_info teacher_training_url}.freeze

  FIELDS_TO_STRIP = %i{
    start_time end_time admin_contact_email admin_contact_phone
  }.freeze

  # Temporary while we're in the process of removing the admin_full_name
  # attribute as the column has a not null constraint
  before_save do
    self.admin_contact_full_name = 'NOT-SET'
  end

  belongs_to :school, class_name: 'Bookings::School'
  validates :school_id, uniqueness: true

  validates :dbs_requires_check, inclusion: [true, false]
  validates :dbs_policy_details, presence: true

  validates :individual_requirements, length: { minimum: 1 }, if: :individual_requirements

  validates :primary_phase, inclusion: [true, false]
  validates :secondary_phase, inclusion: [true, false]
  validates :college_phase, inclusion: [true, false]
  validate :at_least_one_phase

  validates :key_stage_early_years, inclusion: [true, false], if: :primary_phase
  validates :key_stage_1, inclusion: [true, false], if: :primary_phase
  validates :key_stage_2, inclusion: [true, false], if: :primary_phase
  validate  :at_least_one_key_stage, if: :primary_phase

  validates :dress_code_business, inclusion: [true, false]
  validates :dress_code_cover_tattoos, inclusion: [true, false]
  validates :dress_code_remove_piercings, inclusion: [true, false]
  validates :dress_code_smart_casual, inclusion: [true, false]
  validates :dress_code_other_details, length: { minimum: 1 }, if: :dress_code_other_details

  validates :parking_provided, inclusion: [true, false]
  validates :parking_details, presence: true

  validates :disabled_facilities, length: { minimum: 1 }, if: :disabled_facilities

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :flexible_on_times, inclusion: [true, false]
  validates :flexible_on_times_details, presence: true, if: :flexible_on_times

  validates :teacher_training_url, format: URI::regexp(%w{http https}), if: :teacher_training_url

  validates :admin_contact_email, presence: true
  validates :admin_contact_email, format: EMAIL_FORMAT, allow_blank: true
  validates :admin_contact_email_secondary, format: EMAIL_FORMAT, if: :admin_contact_email_secondary
  validates :admin_contact_phone, presence: true
  validates :admin_contact_phone, phone: true, allow_blank: true

  validates :administration_fee_amount_pounds, numericality: { greater_than: 0 }, allow_nil: true
  validates :administration_fee_description, presence: true, if: :administration_fee_assigned
  validates :administration_fee_interval, inclusion: AVAILABLE_INTERVALS, if: :administration_fee_assigned
  validates :administration_fee_payment_method, presence: true, if: :administration_fee_assigned

  validates :dbs_fee_amount_pounds, numericality: { greater_than: 0 }, allow_nil: true
  validates :dbs_fee_description, presence: true, if: :dbs_fee_assigned
  validates :dbs_fee_interval, inclusion: AVAILABLE_INTERVALS, if: :dbs_fee_assigned
  validates :dbs_fee_payment_method, presence: true, if: :dbs_fee_assigned

  validates :other_fee_amount_pounds, numericality: { greater_than: 0 }, allow_nil: true
  validates :other_fee_description, presence: true, if: :other_fee_assigned
  validates :other_fee_interval, inclusion: AVAILABLE_INTERVALS, if: :other_fee_assigned
  validates :other_fee_payment_method, presence: true, if: :other_fee_assigned

  validates :supports_access_needs, inclusion: [true, false]
  validates :access_needs_description, presence: true, if: :supports_access_needs?
  validates :disability_confident, inclusion: [true, false], if: :supports_access_needs?
  validates :has_access_needs_policy, inclusion: [true, false], if: :supports_access_needs?
  validates :access_needs_policy_url, presence: true, if: :has_access_needs_policy?

  validates :access_needs_description, absence: true, unless: :supports_access_needs?
  validates :disability_confident, absence: true, unless: :supports_access_needs?
  validates :has_access_needs_policy, absence: true, unless: :supports_access_needs?
  validates :access_needs_policy_url, absence: true, unless: :has_access_needs_policy?

  before_validation :nilify_blank_fields
  before_validation :strip_fields

  def dress_code
    attributes
      .except('dress_code_other_details')
      .select { |a| a.starts_with?('dress_code') }
      .select { |_, v| v }
      .keys
      .map { |key| key.remove('dress_code_') }
      .map(&:humanize)
      .join(', ')
      .capitalize
  end

  def has_legacy_dbs_requirement?
    dbs_requires_check.nil?
  end

private

  def at_least_one_phase
    unless primary_phase || secondary_phase || college_phase
      errors.add(:base, 'Choose at least one phase')
    end
  end

  def at_least_one_key_stage
    unless key_stage_early_years || key_stage_1 || key_stage_2
      errors.add(:base, 'Choose at least one primary key stage')
    end
  end

  def nilify_blank_fields
    FIELDS_TO_NILIFY.each do |f|
      send(:"#{f}=", nil) if send(f).blank?
    end
  end

  def strip_fields
    FIELDS_TO_STRIP.each do |f|
      send(:"#{f}=", send(f).strip) if send(f).present?
    end
  end

  def administration_fee_assigned
    administration_fee_amount_pounds && administration_fee_amount_pounds.to_f.positive?
  end

  def dbs_fee_assigned
    dbs_fee_amount_pounds && dbs_fee_amount_pounds.to_f.positive?
  end

  def other_fee_assigned
    other_fee_amount_pounds && other_fee_amount_pounds.to_f.positive?
  end
end
