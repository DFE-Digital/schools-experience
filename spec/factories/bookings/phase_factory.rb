FactoryBot.define do
  factory :bookings_phase, class: 'Bookings::Phase' do
    sequence(:name) { |n| "phase #{n}" }
  end

  trait :primary do
    name { 'Primary' }
    edubase_id { 2 }
  end

  trait :secondary do
    name { 'Secondary' }
    edubase_id { 4 }
  end

  trait :college do
    name { '16 plus' }
    edubase_id { 6 }
  end
end
