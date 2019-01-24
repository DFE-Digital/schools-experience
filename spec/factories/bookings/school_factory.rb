FactoryBot.define do
  factory :bookings_school, class: Bookings::School do
    sequence(:name) { |n| "school #{n}" }
    coordinates { Bookings::School::GEOFACTORY.point(-2.241, 53.481) }
  end
end
