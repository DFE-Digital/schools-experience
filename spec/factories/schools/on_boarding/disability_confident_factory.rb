FactoryBot.define do
  factory :disability_confident, class: Schools::OnBoarding::DisabilityConfident do
    is_disability_confident { true }
  end
end
