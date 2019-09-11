FactoryBot.define do
  factory :bookings_placement_date_subject, class: 'Bookings::PlacementDateSubject' do
    bookings_placement_date { nil }
    bookings_subject { nil }
  end
end
