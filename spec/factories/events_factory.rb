FactoryBot.define do
  factory :event do
    association :bookings_candidate, factory: :candidate
    association :bookings_school, factory: :bookings_school
    event_type { 'school_enabled' }

    trait :without_bookings_school do
      bookings_school { nil }
    end

    trait :without_bookings_candidate do
      bookings_candidate { nil }
    end
  end
end
