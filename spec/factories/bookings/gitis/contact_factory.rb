FactoryBot.define do
  factory :gitis_contact, class: 'Bookings::Gitis::Contact' do
    firstname { "Test" }
    sequence(:lastname) { |n| "User#{n}" }
    sequence(:emailaddress1) { |n| "testuser#{n}@testdomain.com" }
    telephone1 { "01234 567890" }
    address1_line1 { "My Building" }
    address1_line2 { "Test Street" }
    address1_city { "Test Town" }
    address1_stateorprovince { "Test County" }
    address1_postalcode { "MA1 1AM" }
    birthdate { '1980-01-01' }
    dfe_channelcreation { 10 }
    dfe_hasdbscertificate { true }
    _dfe_preferredteachingsubject01_value { '04fc5f49-887b-4ac6-82ea-4278e9f3a9c1' }
    _dfe_preferredteachingsubject02_value { '686ba354-2a91-430b-affa-68b4e1fdffc0' }

    trait :persisted do
      contactid { SecureRandom.uuid }
    end
  end
end
