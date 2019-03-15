module Schools
  class SchoolProfile < ApplicationRecord
    composed_of \
      :candidate_requirement,
      class_name: 'Schools::OnBoarding::CandidateRequirement',
      mapping: [
        %w(candidate_requirement_dbs_requirement dbs_requirement),
        %w(candidate_requirement_dbs_policy dbs_policy),
        %w(candidate_requirement_requirements requirements),
        %w(candidate_requirement_requirements_details requirements_details)
      ],
      constructor: :compose

    validates :urn, presence: true

    with_options if: :completed? do
      validate :candidate_requirement_valid
    end

  private

    def completed?
      false
    end

    def candidate_requirement_valid
      unless candidate_requirement.dup.valid?
        errors.add :base, 'candidate_requirement invalid'
      end
    end
  end
end
