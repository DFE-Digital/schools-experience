FactoryBot.define do
  factory :personal_information, class: 'Candidates::Registrations::PersonalInformation' do
    urn { 11_048 }
    first_name { 'Testy' }
    last_name { 'Mc Test' }
    email { 'test@example.com' }
  end
end
