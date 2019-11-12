FactoryBot.define do
  factory :personal_information, class: Candidates::Registrations::PersonalInformation do
    urn { 11048 }
    first_name { 'Testy' }
    last_name { 'Mc Test' }
    email { 'test@example.com' }
    date_of_birth { Date.parse '2000-01-01' }
  end
end
