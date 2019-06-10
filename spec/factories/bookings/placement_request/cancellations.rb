FactoryBot.define do
  factory :cancellation, class: 'Bookings::PlacementRequest::Cancellation' do
    association :placement_request
    reason { "MyText" }
    cancelled_by { 'candidate' }

    trait :sent do
      after :build, &:sent!
    end
  end
end
