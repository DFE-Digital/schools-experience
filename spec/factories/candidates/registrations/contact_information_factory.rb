FactoryBot.define do
  factory :contact_information, class: Candidates::Registrations::ContactInformation do
    full_name { 'Testy McTest' }
    email { 'test@example.com' }
    building { 'New house' }
    street { 'Test street' }
    town_or_city { 'Test Town' }
    county { 'Testshire' }
    postcode { 'TE57 1NG' }
    phone { '01234567890' }
  end
end
