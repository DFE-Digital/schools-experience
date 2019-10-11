FactoryBot.define do
  factory :cancellation, class: 'Bookings::PlacementRequest::Cancellation' do
    association :placement_request
    reason { "MyText" }
    cancelled_by { 'candidate' }

    trait :cancelled_by_school do
      cancelled_by { 'school' }
    end

    trait :cancelled_by_candidate do
      cancelled_by { 'candidate' }
    end

    trait :sent do
      after :build, &:sent!
    end

    trait :viewed do
      viewed_at { DateTime.now }
    end
  end
end
