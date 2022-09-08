FactoryBot.define do
  factory :cancellation, class: 'Bookings::PlacementRequest::Cancellation' do
    association :placement_request
    reason { "MyText" }
    cancelled_by { 'candidate' }

    trait :cancelled_by_school do
      fully_booked { true }
      cancelled_by { 'school' }
      sent
    end

    trait :cancelled_by_candidate do
      cancelled_by { 'candidate' }
    end

    trait :sent do
      sent_at { DateTime.now }
    end

    trait :viewed do
      viewed_at { DateTime.now }
    end
  end
end
