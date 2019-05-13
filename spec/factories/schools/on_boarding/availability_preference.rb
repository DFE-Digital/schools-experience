FactoryBot.define do
  factory :availability_preference, class: 'Schools::OnBoarding::AvailabilityPreference' do
    fixed { false }

    trait :fixed do
      fixed { true }
    end

    trait :flexible do
      fixed { false }
    end
  end
end
