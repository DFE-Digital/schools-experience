module Candidates
  class SchoolPresenter
    include ActionView::Helpers::TextHelper

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
      :administration_fee_description, :administration_fee_payment_method, to: :profile

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
        if key.to_s =~ /dress_code_/ &&
            key.to_s != 'dress_code_other_details' &&
            value == true

          profile.class.human_attribute_name(key)
        end
      end

      dc_attrs.compact.join(', ')
    end

    def dress_code?
      dress_code_other_details.present? || dress_code.present?
    end

    def formatted_dress_code
      return unless dress_code?

      simple_format [dress_code, dress_code_other_details].join("\n\n")
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

    def primary_dates
      school
        .bookings_placement_dates
        .not_supporting_subjects
    end

    def secondary_dates
      school
        .bookings_placement_dates
        .supporting_subjects
        .eager_load(:placement_date_subjects, :subjects).available
    end

    def secondary_dates_grouped_by_date
      secondary_dates
        .group_by(&:date)
        .each
        .with_object({}) do |(date, placement_date), hash|
          hash[date] = placement_date_subjects(placement_date)
        end
    end

  private

    def placement_date_subjects(placement_date)
      placement_date
        .flat_map { |pd| pd.has_subjects? ? pd.subjects.map(&:name) : 'All subjects' }
        .uniq
    end

    def dbs_requirement
      if profile.dbs_requires_check?
        'Yes'
      else
        'No - Candidates will be accompanied at all times'
      end
    end

    def legacy_dbs_requirement
      case profile.dbs_required
      when 'always' then 'Yes - Always'
      when 'sometimes' then 'Yes - Sometimes'
      when 'never' then 'No - Candidates will be accompanied at all times'
      end
    end
  end
end
