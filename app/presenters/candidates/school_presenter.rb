module Candidates
  class SchoolPresenter
    include TextFormattingHelper

    attr_reader :school, :profile

    delegate :name, :urn, :coordinates, :website, to: :school
    delegate :availability_preference_fixed?, to: :school

    delegate :experience_details, :individual_requirements, to: :profile
    delegate :description_details, :disabled_facilities, to: :profile
    delegate :teacher_training_info, :teacher_training_url, to: :profile
    delegate :parking_provided, :parking_details, to: :profile
    delegate :start_time, :end_time, to: :profile
    delegate :flexible_on_times, :flexible_on_times_details, to: :profile
    delegate :dress_code_other_details, to: :profile
    delegate :availability_info, to: :school

    delegate :administration_fee_amount_pounds, :administration_fee_interval, \
      :administration_fee_description, :administration_fee_payment_method, :has_fees?, to: :profile

    delegate :dbs_fee_amount_pounds, :dbs_fee_interval, \
      :dbs_fee_description, :dbs_fee_payment_method, to: :profile

    delegate :other_fee_amount_pounds, :other_fee_interval, \
      :other_fee_description, :other_fee_payment_method, to: :profile

    delegate :supports_access_needs?,
      :access_needs_description,
      :disability_confident?,
      :has_access_needs_policy?,
      :access_needs_policy_url, to: :profile

    def initialize(school, profile)
      @school = school
      @profile = profile
    end

    def dress_code
      dc_attrs = profile.attributes.map do |key, value|
        next unless key.to_s =~ /dress_code_/ &&
          key.to_s != 'dress_code_other_details' &&
          value == true

        profile.class.human_attribute_name(key)
      end

      dc_attrs.compact.join(', ')
    end

    def dress_code?
      dress_code_other_details.present? || dress_code.present?
    end

    def formatted_dress_code
      return unless dress_code?

      safe_format [dress_code, dress_code_other_details].join("\n\n")
    end

    def dbs_required
      if profile.has_legacy_dbs_requirement?
        legacy_dbs_requirement
      else
        dbs_requirement
      end
    end

    def dbs_policy
      if profile.has_legacy_dbs_requirement?
        profile.dbs_policy
      else
        profile.dbs_policy_details
      end
    end

    def total_available_dates
      available_dates_by_month.values.flatten.count
    end

    def available_dates_by_month
      @available_dates_by_month ||= school
        .bookings_placement_dates
        .eager_load(:subjects, placement_date_subjects: :bookings_subject)
        .available
        .group_by { |d| d.date.at_beginning_of_month }
        .transform_values { |v| v.sort_by(&:date) }
    end

  private

    def dbs_requirement
      {
        'required' => 'Yes',
        'inschool' => 'Yes - when in school',
        'notrequired' => 'No - Candidates will be accompanied at all times when in school'
      }[profile.dbs_policy_conditions]
    end

    def legacy_dbs_requirement
      {
        'always' => 'Yes - Always',
        'sometimes' => 'Yes - Sometimes',
        'never' => 'No - Candidates will be accompanied at all times'
      }[profile.dbs_required]
    end
  end
end
