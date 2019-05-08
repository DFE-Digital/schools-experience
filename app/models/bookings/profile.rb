class Bookings::Profile < ApplicationRecord
  DBS_REQUIREMENTS = %w(always sometimes never).freeze
  AVAILABLE_INTERVALS = %w(Daily One-off).freeze
  EMAIL_FORMAT = /\A.*@.*\..*\z/.freeze

  FIELDS_TO_NILIFY = %i{dbs_policy teacher_training_info teacher_training_url}.freeze

  FIELDS_TO_STRIP = %i{
    start_time end_time admin_contact_full_name admin_contact_email admin_contact_phone
  }.freeze

  belongs_to :school, class_name: 'Bookings::School'
  validates :school_id, uniqueness: true

  validates :dbs_required, presence: true
  validates :dbs_required, inclusion: DBS_REQUIREMENTS, unless: -> { dbs_required.nil? }
  validates :dbs_policy, presence: true, if: -> { dbs_required == 'sometimes' }

  validates :individual_requirements, length: { minimum: 1 }, if: :individual_requirements

  validates :primary_phase, inclusion: [true, false]
  validates :secondary_phase, inclusion: [true, false]
  validates :college_phase, inclusion: [true, false]
  validate :at_least_one_phase

  validates :key_stage_early_years, inclusion: [true, false], if: :primary_phase
  validates :key_stage_1, inclusion: [true, false], if: :primary_phase
  validates :key_stage_2, inclusion: [true, false], if: :primary_phase
  validate  :at_least_one_key_stage, if: :primary_phase

  validates :description_details, length: { minimum: 1 }, if: :description_details

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

  validates :placement_info, presence: true

  validates :teacher_training_url, format: URI::regexp(%w{http https}), if: :teacher_training_info

  validates :admin_contact_full_name, presence: true
  validates :admin_contact_email, presence: true
  validates :admin_contact_email, format: EMAIL_FORMAT, allow_blank: true
  validates :admin_contact_phone, presence: true
  validates :admin_contact_phone, phone: true, allow_blank: true

  validates :fixed_availability, inclusion: [true, false]
  validates :availability_info, presence: true, unless: :fixed_availability
  validate :availability_info_is_blank, if: :fixed_availability

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

  before_validation :nilify_blank_fields
  before_validation :strip_fields

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

  def availability_info_is_blank
    if availability_info && !availability_info.blank?
      errors.add :availability_info, 'cannot be set if using fixed availibility'
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
