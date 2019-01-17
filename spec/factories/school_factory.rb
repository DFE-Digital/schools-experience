FactoryBot.define do
  factory :school, class: School do
    sequence(:name) { |n| "school #{n}" }
    coordinates { School::GEOFACTORY.point(-2.241, 53.481) }
  end
end
