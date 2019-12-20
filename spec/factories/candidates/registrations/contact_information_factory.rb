FactoryBot.define do
  factory :contact_information, class: Candidates::Registrations::ContactInformation do
    urn { 11048 }
    building { 'New house' }
    street { 'Test street' }
    town_or_city { 'Test Town' }
    county { 'Testshire' }
    postcode { 'TE57 1NG' }
    phone { '01234567890' }
  end
end
