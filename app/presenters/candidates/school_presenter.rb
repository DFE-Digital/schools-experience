module Candidates
  class SchoolPresenter
    include ActionView::Helpers::TextHelper

    attr_reader :school, :profile

    delegate :name, :urn, :coordinates, :website, to: :school
    delegate :availability_preference_fixed?, to: :school
    delegate :availability_info, to: :school

    delegate :experience_details, :individual_requirements, to: :profile
    delegate :description_details, :disabled_facilities, to: :profile
    delegate :teacher_training_info, :teacher_training_url, to: :profile
    delegate :dbs_policy, :parking_provided, :parking_details, to: :profile
    delegate :start_time, :end_time, :flexible_on_times, to: :profile
    delegate :dress_code_other_details, to: :profile

    delegate :administration_fee_amount_pounds, :administration_fee_interval, \
      :administration_fee_description, :administration_fee_payment_method, to: :profile

    delegate :dbs_fee_amount_pounds, :dbs_fee_interval, \
      :dbs_fee_description, :dbs_fee_payment_method, to: :profile

    delegate :other_fee_amount_pounds, :other_fee_interval, \
      :other_fee_description, :other_fee_payment_method, to: :profile

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
      case profile.dbs_required
      when 'always' then 'Yes - Always'
      when 'sometimes' then 'Yes - Sometimes'
      when 'never' then 'No - Candidates will be accompanied at all times'
      end
    end
  end
end
