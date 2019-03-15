module Schools
  module OnBoarding
    class CandidateRequirement
      include ActiveModel::Model
      include ActiveModel::Attributes

      DBS_REQUIRMENTS = %w(always sometimes never).freeze

      attribute :dbs_requirement, :string
      attribute :dbs_policy, :string
      attribute :requirements, :boolean
      attribute :requirements_details, :string

      validates :dbs_requirement, presence: true
      validates :dbs_requirement, inclusion: { in: :dbs_requirements }, if: -> { dbs_requirement.present? }
      validates :dbs_policy, presence: true, if: :requires_policy_explination?
      validates :requirements, inclusion: [true, false]
      validates :requirements_details, presence: true, if: :requirements

      def self.compose(dbs_requirement, dbs_policy, requirements, requirements_details)
        new \
          dbs_requirement: dbs_requirement,
          dbs_policy: dbs_policy,
          requirements: requirements,
          requirements_details: requirements_details
      end

      def ==(other)
        other.respond_to?(:attributes) && other.attributes == self.attributes
      end

      def dbs_requirements
        DBS_REQUIRMENTS
      end

      def policy_explination_required?(some_dbs_requirement)
        some_dbs_requirement == 'sometimes'
      end

    private

      def requires_policy_explination?
        policy_explination_required? dbs_requirement
      end
    end
  end
end
