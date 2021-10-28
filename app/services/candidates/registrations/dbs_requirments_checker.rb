module Candidates
  module Registrations
    class DbsRequirmentsChecker
      def initialize(school, bg_check, current_registration)
        @school = school
        @bg_check = bg_check
        @current_registration = current_registration
      end

      def requirements_met?
        candidate_has_dbs? ||
          dbs_is_not_required? ||
          school_does_dbs_checks? ||
          (dbs_required_only_for_inschool? && !inschool_request?)
      end

    private

      def school_does_dbs_checks?
        @school.profile&.dbs_fee_amount_pounds?
      end

      def dbs_is_not_required?
        @school.profile&.dbs_policy_conditions == "notrequired"
      end

      def dbs_required_only_for_inschool?
        @school.profile&.dbs_policy_conditions == "inschool"
      end

      def candidate_has_dbs?
        @bg_check.has_dbs_check == true
      end

      def inschool_request?
        if @school.availability_preference_fixed
          @current_registration.subject_and_date_information.placement_date.virtual == false
        else
          @school.experience_type == 'inschool'
        end
      end
    end
  end
end
