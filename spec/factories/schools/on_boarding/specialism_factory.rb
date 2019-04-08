FactoryBot.define do
  factory :specialism, class: Schools::OnBoarding::Specialism do
    has_specialism { true }
    details { 'Horse archery' }
  end
end
