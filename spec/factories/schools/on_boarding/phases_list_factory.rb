FactoryBot.define do
  factory :phases_list, class: Schools::OnBoarding::PhasesList do
    primary { true }
    secondary { true }
    college { true }
    secondary_and_college { true }
  end
end
