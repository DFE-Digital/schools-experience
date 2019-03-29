FactoryBot.define do
  factory :dbs_fee, class: Schools::OnBoarding::DBSFee do
    amount_pounds { 200 }
    description { 'DBS check' }
    interval { 'One-off' }
    payment_method { 'Ethereum' }
  end
end
