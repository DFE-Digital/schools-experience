module Candidates
  module Registrations
    class DbsRequirmentsChecker
      def initialize(school, bg_check, current_registration)
        @school = school
        @bg_check = bg_check
        @current_registration = current_registration
      end

      def requirements_met?
        dbs_is_not_required? || candidate_has_dbs? || (dbs_only_for_inschool? && virtual_experience?)
      end

    private

      def dbs_is_not_required?
        @school.profile&.dbs_policy_conditions == "notrequired"
      end

      def dbs_only_for_inschool?
        @school.profile&.dbs_policy_conditions == "inschool"
      end

      def candidate_has_dbs?
        @bg_check.has_dbs_check == true
      end

      def virtual_experience?
        @current_registration.subject_and_date_information.placement_date.virtual?
      end
    end
  end
end
