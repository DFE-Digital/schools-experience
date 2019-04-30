FactoryBot.define do
  factory :bookings_placement_date, class: 'Bookings::PlacementDate' do
    date { 3.weeks.from_now }
    association :bookings_school, factory: :bookings_school

    trait :in_the_past do
      date { 6.weeks.ago }
    end

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end
  end
end
