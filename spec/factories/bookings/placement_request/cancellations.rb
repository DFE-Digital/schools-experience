FactoryBot.define do
  factory :cancellation, class: 'Bookings::PlacementRequest::Cancellation' do
    association :placement_request
    reason { "MyText" }
    cancelled_by { 'candidate' }
  end
end
