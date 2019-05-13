FactoryBot.define do
  factory :other_fee, class: Schools::OnBoarding::OtherFee do
    amount_pounds { 300 }
    description { 'Falconry lessons' }
    interval { 'One-off' }
    payment_method { 'Gold sovereigns' }
  end
end
