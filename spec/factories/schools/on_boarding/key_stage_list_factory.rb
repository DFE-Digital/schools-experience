FactoryBot.define do
  factory :key_stage_list, class: Schools::OnBoarding::KeyStageList do
    early_years { true }
    key_stage_1 { true }
    key_stage_2 { true }
  end
end
