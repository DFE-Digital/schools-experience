FactoryBot.define do
  factory :dbs_requirement, class: Schools::OnBoarding::DbsRequirement do
    dbs_policy_conditions { 'required' }
    dbs_policy_details { 'Must have recent dbs check' }
    no_dbs_policy_details { nil }
  end
end
