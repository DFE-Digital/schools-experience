FactoryBot.define do
  factory :bookings_phase, class: 'Bookings::Phase' do
    sequence(:name) { |n| "phase #{n}" }
  end

  trait :early_years do
    name { 'Early years' }
    edubase_id { 1 }
    supports_subjects { false }
  end

  trait :primary do
    name { 'Primary (4 to 11)' }
    edubase_id { 2 }
    supports_subjects { false }
  end

  trait :secondary do
    name { 'Secondary (11 to 16)' }
    edubase_id { 4 }
    supports_subjects { true }
  end

  trait :college do
    name { '16 to 18' }
    edubase_id { 6 }
    supports_subjects { true }
  end
end
