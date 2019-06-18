FactoryBot.define do
  factory :candidate, class: 'Bookings::Candidate' do
    gitis_uuid { SecureRandom.uuid }

    trait :confirmed do
      confirmed_at { 5.minutes.ago }
    end
  end
end
