FactoryBot.define do
  factory :bookings_booking, class: 'Bookings::Booking' do
    association :bookings_school, factory: :bookings_school
    association :bookings_subject, factory: :bookings_subject
    association :bookings_placement_request, factory: :bookings_placement_request

    date { 2.months.from_now }
  end
end
