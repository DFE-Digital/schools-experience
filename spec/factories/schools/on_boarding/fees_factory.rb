FactoryBot.define do
  factory :fees, class: Schools::OnBoarding::Fees do
    administration_fees { true }
    dbs_fees { true }
    other_fees { true }
  end
end
