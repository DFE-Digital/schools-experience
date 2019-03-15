FactoryBot.define do
  factory :candidate_requirement, class: Schools::OnBoarding::CandidateRequirement do
    dbs_requirement { 'sometimes' }
    dbs_policy { 'Super secure' }
    requirements { true }
    requirements_details { 'Gotta go fast' }
  end
end
