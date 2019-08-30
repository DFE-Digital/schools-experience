FactoryBot.define do
  factory :candidate_requirement, class: Schools::OnBoarding::CandidateRequirement do
    requirements { true }
    requirements_details { 'Gotta go fast' }
  end
end
