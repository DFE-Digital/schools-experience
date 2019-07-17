FactoryBot.define do
  factory :event do
    gitis_uuid { "1b505657-37ea-4163-b50e-5503eed386ab" }
    association :bookings_school, factory: :bookings_school
    event_type { 'school_enabled' }

    trait :without_bookings_school do
      bookings_school { nil }
      bookings_school_id { nil }
    end

    trait :without_gitis_uuid do
      gitis_uuid { nil }
    end
  end
end
