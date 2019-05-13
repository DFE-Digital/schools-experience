FactoryBot.define do
  factory :bookings_phase, class: 'Bookings::Phase' do
    sequence(:name) { |n| "phase #{n}" }
  end

  trait :early_years do
    name { 'Early years' }
    edubase_id { 1 }
  end

  trait :primary do
    name { 'Primary (4 to 11)' }
    edubase_id { 2 }
  end

  trait :secondary do
    name { 'Secondary (11 to 16)' }
    edubase_id { 4 }
  end

  trait :college do
    name { '16 to 18' }
    edubase_id { 6 }
  end
end
