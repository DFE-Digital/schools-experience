FactoryBot.define do
  factory :school, class: Bookings::School do
    sequence(:name) { |n| "school #{n}" }
    coordinates { Bookings::School::GEOFACTORY.point(-2.241, 53.481) }
  end
end
