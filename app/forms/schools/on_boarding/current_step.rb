# Todo find a better dir for this
module Schools
  module OnBoarding
    class CurrentStep
      def self.for(school_profile)
        new(school_profile).call
      end

      def initialize(school_profile)
        @school_profile = school_profile
      end

      def call
        if dbs_requirement_required?
          :dbs_requirement
        elsif candidate_requirement_required?
          :candidate_requirement
        elsif candidate_requirements_choice_required?
          :candidate_requirements_choice
        elsif candidate_requirements_selection_required?
          :candidate_requirements_selection
        elsif fees_required?
          :fees
        elsif administration_fee_required?
          :administration_fee
        elsif dbs_fee_required?
          :dbs_fee
        elsif other_fees_required?
          :other_fee
        elsif phases_list_required?
          :phases_list
        elsif key_stage_list_required?
          :key_stage_list
        elsif subjects_required?
          :subjects
        elsif description_required?
          :description
        elsif candidate_experience_detail_required?
          :candidate_experience_detail
        elsif access_needs_support_required?
          :access_needs_support
        elsif experience_outline_required?
          :experience_outline
        elsif admin_contact_required?
          :admin_contact
        else
          :COMPLETED
        end
      end

    private

      def dbs_requirement_required?
        !@school_profile.dbs_requirement.dup.valid?
      end

      def candidate_requirement_required?
        return false unless @school_profile.show_candidate_requirement?

        @school_profile.candidate_requirement.dup.invalid?
      end

      def candidate_requirements_choice_required?
        return false unless @school_profile.show_candidate_requirements_selection?

        @school_profile.candidate_requirements_choice.dup.invalid?
      end

      def candidate_requirements_selection_required?
        return false unless @school_profile.show_candidate_requirements_selection?

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

      def other_fees_required?
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

      def experience_outline_required?
        @school_profile.experience_outline.dup.invalid?
      end

      def admin_contact_required?
        @school_profile.admin_contact.dup.invalid?
      end
    end
  end
end
