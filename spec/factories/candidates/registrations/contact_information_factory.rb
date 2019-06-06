FactoryBot.define do
  factory :contact_information, class: Candidates::Registrations::ContactInformation do
    first_name { 'Testy' }
    last_name { 'Mc Test' }
    email { 'test@example.com' }
    building { 'New house' }
    street { 'Test street' }
    town_or_city { 'Test Town' }
    county { 'Testshire' }
    postcode { 'TE57 1NG' }
    phone { '01234567890' }
  end
end
