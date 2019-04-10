FactoryBot.define do
  factory :administration_fee, class: Schools::OnBoarding::AdministrationFee do
    amount_pounds { 100.99 }
    description { 'Generic administration fee' }
    interval { 'Daily' }
    payment_method { 'Cold hard cash' }
  end
end
