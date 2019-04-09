FactoryBot.define do
  factory :school_profile, class: 'Schools::SchoolProfile' do
    candidate_requirement_dbs_requirement { 'sometimes' }
    candidate_requirement_dbs_policy { 'Super secure' }
    candidate_requirement_requirements { true }
    candidate_requirement_requirements_details { 'Gotta go fast' }
  end
end
