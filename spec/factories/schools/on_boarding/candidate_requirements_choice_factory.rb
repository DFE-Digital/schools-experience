FactoryBot.define do
  factory :candidate_requirements_choice, class: Schools::OnBoarding::CandidateRequirementsChoice do
    has_requirements { true }
  end
end
