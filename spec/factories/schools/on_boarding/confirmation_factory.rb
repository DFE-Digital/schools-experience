FactoryBot.define do
  factory :confirmation, class: Schools::OnBoarding::Confirmation do
    acceptance { true }
  end
end
