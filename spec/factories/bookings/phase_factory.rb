FactoryBot.define do
  factory :bookings_phase, class: 'Bookings::Phase' do
    sequence(:name) { |n| "phase #{n}" }
  end

  trait :primary do
    name { 'Primary' }
  end

  trait :secondary do
    name { 'Secondary' }
  end

  trait :college do
    name { '16 plus' }
  end
end
