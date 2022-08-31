module Schools
  module OnBoarding
    class Wizard
      class StepNotFoundError < RuntimeError; end

      attr_reader :school_profile

      SECTIONS = {
        safeguarding_and_fees: %i[
          dbs_requirement
          fees
          administration_fee
          dbs_fee
          other_fee
        ],
        subjects_and_education_phases: %i[
          phases_list
          key_stage_list
          subjects
        ],
        candidate_requirements_and_school_experience_details: %i[
          candidate_requirements_selection
          description
          candidate_dress_code
          candidate_parking_information
          candidate_experience_schedule
          experience_outline
          teacher_training
        ],
        disability_and_access: %i[
          access_needs_support
          access_needs_detail
          disability_confident
          access_needs_policy
        ],
        admin_contact_details: %i[
          admin_contact
        ],
      }.freeze

      def initialize(school_profile)
        @school_profile = school_profile
      end

      def next_step(previous_step)
        remaining_steps = remaining_steps_in_section(previous_step)

        return nil if remaining_steps.none?

        remaining_steps.detect(&method(:required?))
      end

      def step_state(step)
        return :not_started if required?(step)
        return :cannot_start_yet unless can_start?(step)
        return :not_applicable unless applicable?(step)

        :complete
      end

      def completed?
        all_steps.none?(&method(:required?))
      end

      def count_completed_sections
        SECTIONS.select { |_section, steps| steps.none?(&method(:required?)) }.count
      end

    private

      def all_steps
        SECTIONS.values.flatten
      end

      def section_key(step)
        section_info = SECTIONS.invert.find { |steps, _section| step.in?(steps) }
        raise StepNotFoundError, "#{step} step not found" if section_info.nil?

        section_info.last
      end

      def remaining_steps_in_section(after_step)
        steps_in_section = SECTIONS[section_key(after_step)]
        steps_in_section[(steps_in_section.index(after_step) + 1)..]
      end

      def required?(step)
        send("#{step}_required?")
      end

      def applicable?(step)
        return true unless respond_to?("#{step}_applicable?", true)

        send("#{step}_applicable?")
      end

      def can_start?(step)
        return true unless respond_to?("#{step}_can_start?", true)

        send("#{step}_can_start?")
      end

      def dbs_requirement_required?
        school_profile.dbs_requirement.dup.invalid?
      end

      def candidate_requirements_selection_required?
        school_profile.candidate_requirements_selection.dup.invalid? ||
          !school_profile.candidate_requirements_selection_step_completed?
      end

      def fees_required?
        school_profile.fees.dup.invalid?
      end

      def administration_fee_required?
        administration_fee_applicable? &&
          (school_profile.administration_fee.dup.invalid? || !@school_profile.administration_fee_step_completed?)
      end

      def administration_fee_applicable?
        school_profile.fees.administration_fees?
      end

      def administration_fee_can_start?
        !fees_required?
      end

      def dbs_fee_required?
        dbs_fee_applicable? &&
          (school_profile.dbs_fee.dup.invalid? || !@school_profile.dbs_fee_step_completed?)
      end

      def dbs_fee_applicable?
        school_profile.fees.dbs_fees?
      end

      def dbs_fee_can_start?
        !fees_required?
      end

      def other_fee_required?
        other_fee_applicable? &&
          (school_profile.other_fee.dup.invalid? || !@school_profile.other_fee_step_completed?)
      end

      def other_fee_applicable?
        school_profile.fees.other_fees?
      end

      def other_fee_can_start?
        !fees_required?
      end

      def phases_list_required?
        school_profile.phases_list.dup.invalid?
      end

      def key_stage_list_required?
        key_stage_list_applicable? && school_profile.key_stage_list.dup.invalid?
      end

      def key_stage_list_applicable?
        school_profile.phases_list.primary?
      end

      def key_stage_list_can_start?
        !phases_list_required?
      end

      def subjects_required?
        school_profile.subjects.none? && subjects_applicable?
      end

      def subjects_applicable?
        school_profile.phases_list.secondary? || school_profile.phases_list.college?
      end

      def subjects_can_start?
        !phases_list_required?
      end

      def description_required?
        school_profile.description.dup.invalid?
      end

      def candidate_dress_code_required?
        !school_profile.candidate_dress_code_step_completed?
      end

      def candidate_parking_information_required?
        school_profile.candidate_parking_information.dup.invalid?
      end

      def candidate_experience_schedule_required?
        school_profile.candidate_experience_schedule.dup.invalid?
      end

      def access_needs_support_required?
        school_profile.access_needs_support.dup.invalid?
      end

      def access_needs_detail_required?
        access_needs_detail_applicable? && school_profile.access_needs_detail.dup.invalid?
      end

      def access_needs_detail_applicable?
        school_profile.access_needs_support.supports_access_needs?
      end

      def access_needs_detail_can_start?
        !access_needs_support_required?
      end

      def disability_confident_required?
        disability_confident_applicable? && school_profile.disability_confident.dup.invalid?
      end

      def disability_confident_applicable?
        school_profile.access_needs_support.supports_access_needs?
      end

      def disability_confident_can_start?
        !access_needs_support_required?
      end

      def access_needs_policy_required?
        access_needs_policy_applicable? && school_profile.access_needs_policy.dup.invalid?
      end

      def access_needs_policy_applicable?
        school_profile.access_needs_support.supports_access_needs?
      end

      def access_needs_policy_can_start?
        !access_needs_support_required?
      end

      def experience_outline_required?
        school_profile.experience_outline.dup.invalid?
      end

      def teacher_training_required?
        school_profile.teacher_training.dup.invalid?
      end

      def admin_contact_required?
        school_profile.admin_contact.dup.invalid?
      end
    end
  end
end
