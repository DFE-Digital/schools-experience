FactoryBot.define do
  factory :gitis_subject, class: 'Bookings::Gitis::TeachingSubject' do
    dfe_teachingsubjectlistid { SecureRandom.uuid }
    sequence(:dfe_name) { |i| "Gitis Subject #{i}" }
  end
end
