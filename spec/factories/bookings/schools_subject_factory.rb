FactoryBot.define do
  factory :bookings_schools_subject, class: 'Bookings::SchoolsSubject' do
    association :bookings_school, factory: :bookings_school
    association :bookings_subject, factory: :bookings_subject
  end
end
