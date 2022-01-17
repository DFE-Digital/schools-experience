module Bookings
  class ProfileAttributesConvertor
    attr_reader :input

    def initialize(schools_profile_attrs)
      @input = schools_profile_attrs.symbolize_keys
    end

    def attributes
      reset_output

      convert_dbs_profile
      convert_individual_requirements
      convert_dress_code
      convert_teacher_training
      convert_admin_details
      copy_phases
      copy_key_stages
      copy_parking
      copy_fields
      convert_description
      convert_fees(:administration)
      convert_fees(:dbs)
      convert_fees(:other)
      convert_access_needs

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

    def convert_dbs_profile
      output[:dbs_policy_conditions] = input[:dbs_requirement_dbs_policy_conditions]

      output[:dbs_policy_details] = case input[:dbs_requirement_dbs_policy_conditions]
                                    when 'notrequired'
                                      input[:dbs_requirement_no_dbs_policy_details].presence
                                    when 'inschool'
                                      input[:dbs_requirement_dbs_policy_details_inschool].presence
                                    else
                                      input[:dbs_requirement_dbs_policy_details].presence
                                    end
    end

    def convert_individual_requirements
      output[:individual_requirements] = \
        Schools::OnBoarding::CandidateRequirementsSelectionPresenter.new(input).to_s
    end

    def convert_dress_code
      output[:dress_code_business] = input[:candidate_experience_detail_business_dress].present?
      output[:dress_code_cover_tattoos] = input[:candidate_experience_detail_cover_up_tattoos].present?
      output[:dress_code_remove_piercings] = input[:candidate_experience_detail_remove_piercings].present?
      output[:dress_code_smart_casual] = input[:candidate_experience_detail_smart_casual].present?

      output[:dress_code_other_details] = \
        conditional_assign(:candidate_experience_detail_other_dress_requirements,
          :candidate_experience_detail_other_dress_requirements_detail)
    end

    def convert_admin_details
      output[:admin_contact_email] = input[:admin_contact_email].presence

      if output[:admin_contact_email].present?
        output[:admin_contact_email_secondary] = input[:admin_contact_email_secondary].presence
        output[:admin_contact_phone] = input[:admin_contact_phone].presence
      else
        output[:admin_contact_email] = \
          output[:admin_contact_email_secondary] = output[:admin_contact_phone] = nil
      end
    end

    def copy_phases
      output[:primary_phase]    = input[:phases_list_primary].present?
      output[:secondary_phase]  = input[:phases_list_secondary].present? || input[:phases_list_secondary_and_college].present?
      output[:college_phase]    = input[:phases_list_college].present? || input[:phases_list_secondary_and_college].present?
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
      output[:flexible_on_times]      = input[:candidate_experience_detail_times_flexible].present?
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
      if input[:teacher_training_provides_teacher_training]
        output[:teacher_training_info]  = input[:teacher_training_teacher_training_details]
        output[:teacher_training_url]   = input[:teacher_training_teacher_training_url].presence
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

    def convert_access_needs
      if input.fetch(:access_needs_support_supports_access_needs)
        output[:supports_access_needs]    = input.fetch(:access_needs_support_supports_access_needs)
        output[:access_needs_description] = input.fetch(:access_needs_detail_description)
        output[:disability_confident]     = input.fetch(:disability_confident_is_disability_confident)
        output[:has_access_needs_policy]  = input.fetch(:access_needs_policy_has_access_needs_policy)
        output[:access_needs_policy_url]  = input.fetch(:access_needs_policy_url)
      else
        output[:supports_access_needs]    = false
        output[:access_needs_description] = nil
        output[:disability_confident]     = nil
        output[:has_access_needs_policy]  = nil
        output[:access_needs_policy_url]  = nil
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
