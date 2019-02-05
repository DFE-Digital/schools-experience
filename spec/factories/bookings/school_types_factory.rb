FactoryBot.define do
  factory :bookings_school_type, class: 'Bookings::SchoolType' do
    sequence(:name) { |n| "school type #{n}" }
  end
end
