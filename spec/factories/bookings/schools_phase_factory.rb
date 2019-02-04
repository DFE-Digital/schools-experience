FactoryBot.define do
  factory :bookings_schools_phase, class: 'Bookings::SchoolsPhase' do
    association :bookings_school, factory: :bookings_school
    association :bookings_phase, factory: :bookings_phase
  end
end
