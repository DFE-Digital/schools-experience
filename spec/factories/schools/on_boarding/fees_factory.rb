FactoryBot.define do
  factory :fees, class: 'Schools::OnBoarding::Fees' do
    selected_fees { %w[administration_fees dbs_fees other_fees] }
    dbs_fees_specified { true }
  end
end
