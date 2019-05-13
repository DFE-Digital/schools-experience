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
        other.school_profile_id == self.school_profile_id
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
        @school.contact_email
      end

      def fees
        output = []

        if @school_profile.fees.administration_fees
          output << description_for_fee(@school_profile.administration_fee)
        end

        if @school_profile.fees.dbs_fees
          output << description_for_fee(@school_profile.dbs_fee)
        end

        if @school_profile.fees.other_fees
          output << description_for_fee(@school_profile.other_fee)
        end

        if output.empty?
          'No'
        else
          'Yes - ' + output.to_sentence
        end
      end

      def dbs_check_required
        case @school_profile.candidate_requirement.dbs_requirement
        when 'always'
          'Yes - Always'
        when 'sometimes'
          'Yes - Sometimes. ' + @school_profile.candidate_requirement.dbs_policy
        when 'never'
          'No - Candidates will be accompanied at all times'
        else
          fail "Unknown dbs_requirement profile: #{@school_profile.inspect}"
        end
      end

      def individual_requirements
        if @school_profile.candidate_requirement.requirements
          'Yes - ' + @school_profile.candidate_requirement.requirements_details
        else
          'No'
        end
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

        fail "No phases for #{@school_profile.inspect}" if output.empty?

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

        @school_profile.subjects.pluck(:name).to_sentence
      end

      def descriptions
        @school_profile.description.details
      end

      def school_experience_details
        @school_profile.experience_outline.candidate_experience
      end

      def teacher_training_links
        if @school_profile.experience_outline.provides_teacher_training
          details = sanitize(@school_profile.experience_outline.teacher_training_details)
          url = link_to 'Teacher training information', sanitize(@school_profile.experience_outline.teacher_training_url)
          "Yes - #{details}. #{url}".html_safe
        else
          'No'
        end
      end

      def dress_code
        output = []

        if @school_profile.candidate_experience_detail.business_dress
          output << 'business dress'
        end

        if @school_profile.candidate_experience_detail.cover_up_tattoos
          output << 'cover up tattoos'
        end

        if @school_profile.candidate_experience_detail.remove_piercings
          output << 'remove piercings'
        end

        if @school_profile.candidate_experience_detail.smart_casual
          output << 'smart casual'
        end

        if @school_profile.candidate_experience_detail.other_dress_requirements
          output << @school_profile.candidate_experience_detail.other_dress_requirements_detail
        end

        output.to_sentence.capitalize
      end

      def parking
        if @school_profile.candidate_experience_detail.parking_provided
          @school_profile.candidate_experience_detail.parking_details
        else
          @school_profile.candidate_experience_detail.nearby_parking_details
        end
      end

      def disability_and_access_needs
        if @school_profile.candidate_experience_detail.disabled_facilities
          'Yes - ' + @school_profile.candidate_experience_detail.disabled_facilities_details
        else
          'No'
        end
      end

      def start_time
        @school_profile.candidate_experience_detail.start_time
      end

      def end_time
        @school_profile.candidate_experience_detail.end_time
      end

      def flexible_on_times
        if @school_profile.candidate_experience_detail.times_flexible
          'Yes - ' + @school_profile.candidate_experience_detail.times_flexible_details
        else
          'No'
        end
      end

      def availability_type
        if @school_profile.availability_preference.fixed?
          'Fixed'
        else
          'Flexible'
        end
      end

      def availability
        @school_profile.availability_description.description
      end

      def admin_contact_full_name
        @school_profile.admin_contact.full_name
      end

      def admin_contact_phone
        @school_profile.admin_contact.phone
      end

      def admin_contact_email
        @school_profile.admin_contact.email
      end

      def flexible_dates?
        @school_profile.flexible_dates?
      end

    private

      def description_for_fee(fee)
        amount = number_to_currency fee.amount_pounds, unit: '£', raise: true
        name = fee.model_name.human.downcase
        interval = fee.interval.downcase
        [amount, interval, name].join(' ')
      end
    end
  end
end
