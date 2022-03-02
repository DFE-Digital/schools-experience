# Todo find a better dir for this
module Schools
  module OnBoarding
    class CurrentStep
      SECTIONS = {
        dbs_check: %i(dbs_requirement),
        candidate_requirements: %i(candidate_requirements_selection),
        fees: %i(fees administration_fee dbs_fee other_fee),
        stages: %i(phases_list key_stage_list subjects),
        description: %i(description candidate_dress_code candidate_parking_information candidate_experience_schedule),
        disability_and_access: %i(access_needs_support access_needs_detail disability_confident access_needs_policy),
        type_of_experience: %i(experience_outline teacher_training),
        admin_contact_details: %i(admin_contact),
      }.freeze

      def self.for(school_profile, last_step)
        new(school_profile).call(last_step)
      end

      def initialize(school_profile)
        @school_profile = school_profile
      end

      def call(last_step)
        section = SECTIONS.invert.find { |steps, section| last_step.in?(steps) }.last
        steps_in_section = SECTIONS[section]
        last_step_index = steps_in_section.index(last_step)

        if last_step_index == steps_in_section.count
          nil # Go back to progress page
        else
          steps_in_section[(last_step_index + 1)..].detect(&method(:required?))
        end
      end

      def state(step)
        section = SECTIONS.invert.find { |steps, section| step.in?(steps) }.last

        if send("#{step}_required?")
          :not_started
        else
          first_step_in_section = SECTIONS[section].first

          if send("#{first_step_in_section}_required?")
            :cannot_start_yet
          else
            if respond_to?("#{step}_applicable?", true) && !send("#{step}_applicable?")
              :not_applicable
            else
              :complete
            end
          end
        end
      end

      def completed?
        steps = SECTIONS.values.flatten

        steps.none? { |step| send("#{step}_required?") }
      end

      def completed_section_count
        SECTIONS.select do |section, steps|
          steps.none? { |step| send("#{step}_required?") }
        end.count
      end

      private

      def required?(step)
        send "#{step}_required?"
      end

      def dbs_requirement_required?
        !@school_profile.dbs_requirement.dup.valid?
      end

      def candidate_requirements_selection_required?
        return true if @school_profile.candidate_requirements_selection.dup.invalid?

        !@school_profile.candidate_requirements_selection_step_completed?
      end

      def fees_required?
        @school_profile.fees.dup.invalid?
      end

      def administration_fee_required?
        return false unless @school_profile.fees.administration_fees

        return true if @school_profile.administration_fee.dup.invalid?

        !@school_profile.administration_fee_not_set
      end

      def administration_fee_applicable?
        @school_profile.fees.administration_fees
      end

      def dbs_fee_required?
        return false unless @school_profile.fees.dbs_fees

        return true if @school_profile.dbs_fee.dup.invalid?

        !@school_profile.dbs_fee_not_set
      end

      def dbs_fee_applicable?
        @school_profile.fees.dbs_fees
      end

      def other_fee_required?
        return false unless @school_profile.fees.other_fees

        return true if @school_profile.other_fee.dup.invalid?

        !@school_profile.other_fee_not_set
      end

      def other_fee_applicable?
        @school_profile.fees.other_fees
      end

      def phases_list_required?
        @school_profile.phases_list.dup.invalid?
      end

      def key_stage_list_required?
        @school_profile.phases_list.primary? &&
          @school_profile.key_stage_list.dup.invalid?
      end

      def key_stage_list_applicable?
        @school_profile.phases_list.primary?
      end

      def subjects_required?
        return false if @school_profile.subjects.any?

        return true if @school_profile.phases_list.secondary?

        return true if @school_profile.phases_list.college?

        false
      end

      def subjects_applicable?
        @school_profile.phases_list.secondary?
      end

      def description_required?
        @school_profile.description.dup.invalid?
      end

      def candidate_dress_code_required?
        return true if @school_profile.candidate_dress_code.dup.invalid?

        !@school_profile.candidate_dress_code_step_completed?
      end

      def candidate_parking_information_required?
        @school_profile.candidate_parking_information.dup.invalid?
      end

      def candidate_experience_schedule_required?
        @school_profile.candidate_experience_schedule.dup.invalid?
      end

      def access_needs_support_required?
        @school_profile.access_needs_support.dup.invalid?
      end

      def access_needs_detail_required?
        return false unless @school_profile.access_needs_support.supports_access_needs?

        @school_profile.access_needs_detail.dup.invalid?
      end

      def access_needs_detail_applicable?
        @school_profile.access_needs_support.supports_access_needs?
      end

      def disability_confident_required?
        return false unless @school_profile.access_needs_support.supports_access_needs?

        @school_profile.disability_confident.dup.invalid?
      end

      def disability_confident_applicable?
        @school_profile.access_needs_support.supports_access_needs?
      end

      def access_needs_policy_required?
        return false unless @school_profile.access_needs_support.supports_access_needs?

        @school_profile.access_needs_policy.dup.invalid?
      end

      def access_needs_policy_applicable?
        @school_profile.access_needs_support.supports_access_needs?
      end

      def experience_outline_required?
        @school_profile.experience_outline.dup.invalid?
      end

      def teacher_training_required?
        @school_profile.teacher_training.dup.invalid?
      end

      def admin_contact_required?
        @school_profile.admin_contact.dup.invalid?
      end
    end
  end
end
