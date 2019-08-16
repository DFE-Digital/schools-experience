FactoryBot.define do
  factory :dbs_requirement, class: Schools::OnBoarding::DbsRequirement do
    requires_check { true }
    dbs_policy_details { 'Must have recent dbs check' }
    no_dbs_policy_details { nil }
  end
end
