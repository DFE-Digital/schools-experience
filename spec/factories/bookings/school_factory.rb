FactoryBot.define do
  factory :bookings_school, class: Bookings::School do
    sequence(:name) { |n| "school #{n}" }
    coordinates { Bookings::School::GEOFACTORY.point(-2.241, 53.481) }
    fee { 0 }
    sequence(:urn) { |n| 10000 + n }
    sequence(:address_1) { |n| "#{n} Something Street" }
    sequence(:postcode) { |n| "M#{n} 2JF" }
    association :school_type, factory: :bookings_school_type
  end
end
