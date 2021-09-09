module Candidates
  module Registrations
    class RequestRejecter
      def initialize(school, bg_check, cur_registration)
        @school = school
        @bg_check = bg_check
        @cur_registration = cur_registration
      end

      def rejected?
        required_dbs_policy_applies? || inschool_dbs_policy_applies?
      end

    private

      def school_requires_dbs?
        @school.profile&.dbs_policy_conditions == "required"
      end

      def school_requires_dbs_for_inschool_only?
        @school.profile&.dbs_policy_conditions == "inschool"
      end

      def candidate_does_not_have_dbs?
        @bg_check.has_dbs_check == false
      end

      def candidate_requests_inschool_experience?
        !@cur_registration.subject_and_date_information.placement_date.virtual?
      end

      def required_dbs_policy_applies?
        school_requires_dbs? && candidate_does_not_have_dbs?
      end

      def inschool_dbs_policy_applies?
        (school_requires_dbs_for_inschool_only? && candidate_requests_inschool_experience? && candidate_does_not_have_dbs?)
      end
    end
  end
end
