FactoryBot.define do
  factory :cancellation, class: 'Bookings::PlacementRequest::Cancellation' do
    association :placement_request
    reason { "MyText" }
    cancelled_by { 'candidate' }

    trait :cancelled_by_school do
      rejection_category { 'fully_booked' }
      cancelled_by { 'school' }
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
