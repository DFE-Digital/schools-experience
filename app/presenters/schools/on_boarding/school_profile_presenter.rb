module Schools
  module OnBoarding
    class SchoolProfilePresenter
      include ActionView::Helpers

      def initialize(school_profile)
        @school_profile = school_profile
        @school = school_profile.bookings_school
      end

      def school_profile_id
        @school_profile.id
      end

      def ==(other)
        other.school_profile_id == school_profile_id
      end

      def school_name
        @school.name
      end

      def school_address
        [
          @school.address_1,
          @school.address_2,
          @school.address_3,
          @school.town,
          @school.county,
          @school.postcode
        ].map(&:presence).compact.join(', ')
      end

      def school_email
        @school.notification_emails.join ', '
      end

      def fees
        output = []

        if @school_profile.fees.administration_fees?
          output << description_for_fee(@school_profile.administration_fee)
        end

        if @school_profile.fees.dbs_fees?
          output << description_for_fee(@school_profile.dbs_fee)
        end

        if @school_profile.fees.other_fees?
          output << description_for_fee(@school_profile.other_fee)
        end

        if output.empty?
          'No'
        else
          'Yes - ' + output.to_sentence
        end
      end

      def dbs_check
        unless @school_profile.dbs_requirement.dbs_policy_conditions.in? \
          Bookings::Profile::DBS_POLICY_CONDITIONS

          raise "DBS requirement not set #{@school_profile.inspect}"
        end

        case @school_profile.dbs_requirement.dbs_policy_conditions
        when 'required'
          [
            'Yes',
            @school_profile.dbs_requirement.dbs_policy_details
          ].compact.join(' - ')
        when 'inschool'
          [
            'Yes - when in school',
            @school_profile.dbs_requirement.dbs_policy_details_inschool
          ].compact.join(' - ')
        when 'notrequired'
          [
            'No, candidates will be accompanied at all times',
            @school_profile.dbs_requirement.no_dbs_policy_details.presence
          ].compact.join(' - ')
        end
      end

      def individual_requirements
        candidate_requirements_selection
      end

      def school_experience_phases
        output = []

        if @school_profile.phases_list.primary?
          output << 'primary'
        end

        if @school_profile.phases_list.secondary?
          output << 'secondary'
        end

        if @school_profile.phases_list.college?
          output << '16 - 18 years'
        end

        raise "No phases for #{@school_profile.inspect}" if output.empty?

        output.to_sentence.capitalize
      end

      def primary_key_stages_offered?
        @school_profile.phases_list.primary?
      end

      def primary_key_stages
        return 'None' unless primary_key_stages_offered?

        output = []

        if @school_profile.key_stage_list.early_years
          output << 'early years'
        end

        if @school_profile.key_stage_list.key_stage_1
          output << 'key stage 1'
        end

        if @school_profile.key_stage_list.key_stage_2
          output << 'key stage 2'
        end

        output.to_sentence.capitalize
      end

      def subjects_offered?
        @school_profile.requires_subjects?
      end

      def subjects
        return 'None' unless subjects_offered?

        @school_profile.subjects.pluck(:name).sort.to_sentence
      end

      def descriptions
        @school_profile.description.details
      end

      def school_experience_details
        @school_profile.experience_outline.candidate_experience
      end

      def teacher_training_links
        if @school_profile.teacher_training.provides_teacher_training
          details = sanitize(@school_profile.teacher_training.teacher_training_details)
          link = link_to 'Find out more about our teacher training', sanitize(@school_profile.teacher_training.teacher_training_url)

          safe_join ["Yes - #{details}.", link], ' '
        else
          'No'
        end
      end

      def dress_code
        output = []

        if @school_profile.candidate_dress_code.business_dress?
          output << 'business dress'
        end

        if @school_profile.candidate_dress_code.cover_up_tattoos?
          output << 'cover up tattoos'
        end

        if @school_profile.candidate_dress_code.remove_piercings?
          output << 'remove piercings'
        end

        if @school_profile.candidate_dress_code.smart_casual?
          output << 'smart casual'
        end

        if @school_profile.candidate_dress_code.other_dress_requirements?
          output << @school_profile.candidate_dress_code.other_dress_requirements_detail
        end

        if @school_profile.candidate_dress_code.none?
          output << 'none'
        end

        output.to_sentence.capitalize
      end

      def parking
        if @school_profile.candidate_parking_information.parking_provided
          @school_profile.candidate_parking_information.parking_details
        else
          @school_profile.candidate_parking_information.nearby_parking_details
        end
      end

      def supports_access_needs?
        @school_profile.access_needs_support.supports_access_needs?
      end

      def supports_access_needs_description
        if supports_access_needs?
          'Yes'
        else
          'No'
        end
      end

      def disability_and_access_needs_description
        @school_profile.access_needs_detail.description
      end

      def disability_confident_scheme
        if @school_profile.disability_confident.is_disability_confident
          'Yes'
        else
          'No'
        end
      end

      def disability_and_access_needs_policy
        if @school_profile.access_needs_policy.has_access_needs_policy
          @school_profile.access_needs_policy.url
        else
          'None'
        end
      end

      def start_time
        @school_profile.candidate_experience_schedule.start_time
      end

      def end_time
        @school_profile.candidate_experience_schedule.end_time
      end

      def flexible_on_times
        if @school_profile.candidate_experience_schedule.times_flexible
          'Yes - ' + @school_profile.candidate_experience_schedule.times_flexible_details
        else
          'No'
        end
      end

      def admin_contact_phone
        @school_profile.admin_contact.phone
      end

      def admin_contact_email
        @school_profile.admin_contact.email
      end

      def admin_contact_email_secondary
        @school_profile.admin_contact.email_secondary
      end

      def flexible_dates?
        @school_profile.flexible_dates?
      end

    private

      def candidate_requirements
        if @school_profile.candidate_requirement.requirements
          'Yes - ' + @school_profile.candidate_requirement.requirements_details
        else
          'No'
        end
      end

      def candidate_requirements_selection
        CandidateRequirementsSelectionPresenter.new(@school_profile.attributes).to_s
      end

      def description_for_fee(fee)
        amount = number_to_currency fee.amount_pounds, unit: '£', raise: true
        name = fee.model_name.human.downcase
        interval = fee.interval.downcase
        [amount, interval, name].join(' ')
      end
    end
  end
end
