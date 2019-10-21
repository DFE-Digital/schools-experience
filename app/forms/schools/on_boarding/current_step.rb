# Todo find a better dir for this
module Schools
  module OnBoarding
    class CurrentStep
      STEPS = %i(
        dbs_requirement
        candidate_requirements_choice
        candidate_requirements_selection
        fees
        administration_fee
        dbs_fee
        other_fee
        phases_list
        key_stage_list
        subjects
        description
        candidate_experience_detail
        access_needs_support
        access_needs_detail
        disability_confident
        access_needs_policy
        experience_outline
        admin_contact
      ).freeze

      def self.for(school_profile)
        new(school_profile).call
      end

      def initialize(school_profile)
        @school_profile = school_profile
      end

      def call
        STEPS.detect(&method(:required?)) || :COMPLETED
      end

    private

      def required?(step)
        send "#{step}_required?"
      end

      def dbs_requirement_required?
        !@school_profile.dbs_requirement.dup.valid?
      end

      def candidate_requirements_choice_required?
        @school_profile.candidate_requirements_choice.dup.invalid?
      end

      def candidate_requirements_selection_required?
        return false unless @school_profile.candidate_requirements_choice.has_requirements

        return true if @school_profile.candidate_requirements_selection.dup.invalid?

        !@school_profile.candidate_requirements_selection_step_completed?
      end

      def fees_required?
        @school_profile.fees.dup.invalid?
      end

      def administration_fee_required?
        return false unless @school_profile.fees.administration_fees

        return true if @school_profile.administration_fee.dup.invalid?

        !@school_profile.administration_fee_step_completed?
      end

      def dbs_fee_required?
        return false unless @school_profile.fees.dbs_fees

        return true if @school_profile.dbs_fee.dup.invalid?

        !@school_profile.dbs_fee_step_completed?
      end

      def other_fee_required?
        return false unless @school_profile.fees.other_fees

        return true if @school_profile.other_fee.dup.invalid?

        !@school_profile.other_fee_step_completed?
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

      def candidate_experience_detail_required?
        @school_profile.candidate_experience_detail.dup.invalid?
      end

      def access_needs_support_required?
        return false unless Feature.instance.active? :access_needs_journey

        @school_profile.access_needs_support.dup.invalid?
      end

      def access_needs_detail_required?
        return false unless Feature.instance.active? :access_needs_journey
        return false unless @school_profile.access_needs_support.supports_access_needs?

        @school_profile.access_needs_detail.dup.invalid?
      end

      def disability_confident_required?
        return false unless Feature.instance.active? :access_needs_journey
        return false unless @school_profile.access_needs_support.supports_access_needs?

        @school_profile.disability_confident.dup.invalid?
      end

      def access_needs_policy_required?
        return false unless Feature.instance.active? :access_needs_journey
        return false unless @school_profile.access_needs_support.supports_access_needs?

        @school_profile.access_needs_policy.dup.invalid?
      end

      def experience_outline_required?
        @school_profile.experience_outline.dup.invalid?
      end

      def admin_contact_required?
        @school_profile.admin_contact.dup.invalid?
      end
    end
  end
end
