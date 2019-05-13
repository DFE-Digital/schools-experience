module Bookings
  class ProfileAttributesConvertor
    attr_reader :input

    def initialize(schools_profile_attrs)
      @input = schools_profile_attrs.symbolize_keys
    end

    def attributes
      reset_output

      convert_dbs
      convert_nillable
      convert_dress_code
      convert_teacher_training
      convert_admin_details
      copy_phases
      copy_key_stages
      copy_parking
      copy_fields
      convert_availability
      convert_description
      convert_fees(:administration)
      convert_fees(:dbs)
      convert_fees(:other)

      output
    end

    def phase_ids
      Set.new.tap do |ids|
        if input[:phases_list_primary]
          ids << edubase_ids[1] if input[:key_stage_list_early_years]
          ids << edubase_ids[2]
        end

        if input[:phases_list_secondary] || input.fetch(:phases_list_secondary_and_college)
          ids << edubase_ids[4]
        end

        if input[:phases_list_college] || input.fetch(:phases_list_secondary_and_college)
          ids << edubase_ids[6]
        end
      end
    end

  private

    def convert_dbs
      output[:dbs_required] = input[:candidate_requirement_dbs_requirement]

      needs_policy = output[:dbs_required] == 'sometimes'
      output[:dbs_policy] = assign_or_nil(needs_policy, :candidate_requirement_dbs_policy)
    end

    def convert_nillable
      output[:individual_requirements] = \
        conditional_assign(:candidate_requirement_requirements,
          :candidate_requirement_requirements_details)

      output[:disabled_facilities] = \
        conditional_assign(:candidate_experience_detail_disabled_facilities,
          :candidate_experience_detail_disabled_facilities_details)
    end

    def convert_dress_code
      output[:dress_code_business] = !!input[:candidate_experience_detail_business_dress]
      output[:dress_code_cover_tattoos] = !!input[:candidate_experience_detail_cover_up_tattoos]
      output[:dress_code_remove_piercings] = !!input[:candidate_experience_detail_remove_piercings]
      output[:dress_code_smart_casual] = !!input[:candidate_experience_detail_smart_casual]

      output[:dress_code_other_details] = \
        conditional_assign(:candidate_experience_detail_other_dress_requirements,
          :candidate_experience_detail_other_dress_requirements_detail)
    end

    def convert_admin_details
      output[:admin_contact_full_name] = input[:admin_contact_full_name].presence

      if output[:admin_contact_full_name].present?
        output[:admin_contact_email] = input[:admin_contact_email]
        output[:admin_contact_phone] = input[:admin_contact_phone]
      else
        output[:admin_contact_email] = output[:admin_contact_phone] = nil
      end
    end

    def convert_availability
      output[:fixed_availability] = input[:availability_preference_fixed]

      output[:availability_info] = \
        inverse_conditional_assign(:availability_preference_fixed,
          :availability_description_description)
    end

    def copy_phases
      output[:primary_phase]    = !!input[:phases_list_primary]
      output[:secondary_phase]  = !!input[:phases_list_secondary] || !!input[:phases_list_secondary_and_college]
      output[:college_phase]    = !!input[:phases_list_college] || !!input[:phases_list_secondary_and_college]
    end

    def copy_key_stages
      output[:key_stage_early_years] = input[:phases_list_primary] && input[:key_stage_list_early_years]
      output[:key_stage_1]           = input[:phases_list_primary] && input[:key_stage_list_key_stage_1]
      output[:key_stage_2]           = input[:phases_list_primary] && input[:key_stage_list_key_stage_2]
    end

    def copy_fields
      output[:start_time]             = input[:candidate_experience_detail_start_time]
      output[:end_time]               = input[:candidate_experience_detail_end_time]
      output[:experience_details]     = input[:experience_outline_candidate_experience].presence
      output[:flexible_on_times]      = !!input[:candidate_experience_detail_times_flexible]
      output[:flexible_on_times_details] = conditional_assign(
        :candidate_experience_detail_times_flexible,
        :candidate_experience_detail_times_flexible_details
      )
    end

    def copy_parking
      if input[:candidate_experience_detail_parking_provided]
        output[:parking_provided] = true
        output[:parking_details]  = input[:candidate_experience_detail_parking_details]
      else
        output[:parking_provided] = false
        output[:parking_details]  = input[:candidate_experience_detail_nearby_parking_details]
      end
    end

    def convert_teacher_training
      if input[:experience_outline_provides_teacher_training]
        output[:teacher_training_info]  = input[:experience_outline_teacher_training_details]
        output[:teacher_training_url]   = input[:experience_outline_teacher_training_url].presence
      else
        output[:teacher_training_info] = output[:teacher_training_url] = nil
      end
    end

    def convert_description
      output[:description_details] = input[:description_details].presence
    end

    def convert_fees(type)
      if input[:"fees_#{type}_fees"]
        output[:"#{type}_fee_amount_pounds"]  = input[:"#{type}_fee_amount_pounds"]
        output[:"#{type}_fee_description"]    = input[:"#{type}_fee_description"]
        output[:"#{type}_fee_interval"]       = input[:"#{type}_fee_interval"]
        output[:"#{type}_fee_payment_method"] = input[:"#{type}_fee_payment_method"]
      else
        output[:"#{type}_fee_amount_pounds"]  = nil
        output[:"#{type}_fee_description"]    = nil
        output[:"#{type}_fee_interval"]       = nil
        output[:"#{type}_fee_payment_method"] = nil
      end
    end

    def output
      @output ||= {}
    end

    def reset_output
      @output = {}
    end

    def conditional_assign(condition_key, input_key)
      assign_or_nil(!!input[condition_key], input_key)
    end

    def inverse_conditional_assign(condition_key, input_key)
      assign_or_nil(!input[condition_key], input_key)
    end

    def assign_or_nil(test_result, input_key)
      test_result ? input[input_key] : nil
    end

    def edubase_ids
      @edubase_ids ||= Hash[Bookings::Phase.pluck(:edubase_id, :id)]
    end
  end
end
