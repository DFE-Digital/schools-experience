# Todo find a better dir for this
module Schools
  module OnBoarding
    class CurrentStep
      SECTIONS = {
        dbs_check: %i(dbs_requirement),
        candidate_requirements: %i(candidate_requirements_selection),
        fees: %i(fees administration_fee dbs_fee other_fee),
        stages: %i(phases_list key_stage_list subjects),
        description: %i(description),
        candidate_dress_code: %i(candidate_dress_code),
        candidate_dresscandidate_parking_information_code: %i(candidate_parking_information),
        candidate_experience_schedule: %i(candidate_experience_schedule),
        disability_and_access: %i(access_needs_support access_needs_detail disability_confident access_needs_policy),
        type_of_experience: %i(experience_outline),
        teacher_training: %i(teacher_training),
        admin_contact_details: %i(admin_contact),
      }.freeze

      LITE_STEPS = %i[
        admin_contact
        phases_list
        subjects
        dbs_requirement
      ]

      def self.for(school_profile, last_step)
        new(school_profile).call(last_step)
      end

      def self.for_lite(school_profile)
        new(school_profile).call_lite
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

      def incomplete_steps
        SECTIONS.values.flatten.select do |step|
          send("#{step}_required?") && !@school_profile.send(step).dup.valid?
        end
      end

      def lite_completed?
        LITE_STEPS.none? { |step| send("#{step}_required?") }
      end

      def call_lite
        LITE_STEPS.detect(&method(:required?))
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
        @school_profile.fees.administration_fees
      end

      def dbs_fee_required?
        @school_profile.fees.dbs_fees
      end

      def other_fee_required?
        @school_profile.fees.other_fees
      end

      def phases_list_required?
        @school_profile.phases_list.dup.invalid?
      end

      def key_stage_list_required?
        @school_profile.phases_list.primary? &&
          @school_profile.key_stage_list.dup.invalid?
      end

      def subjects_required?
        return false if @school_profile.subjects.any?

        return true if @school_profile.phases_list.secondary?

        return true if @school_profile.phases_list.college?

        false
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
        @school_profile.access_needs_support.supports_access_needs?
      end

      def disability_confident_required?
        @school_profile.access_needs_support.supports_access_needs?
      end

      def access_needs_policy_required?
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
