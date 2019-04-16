FactoryBot.define do
  factory :bookings_placement_date, class: 'Bookings::PlacementDate' do
    date { 3.weeks.from_now }
    association :school_profile, factory: :school_profile

    trait :in_the_past do
      date { 6.weeks.ago }
    end
  end
end
