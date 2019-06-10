FactoryBot.define do
  factory :gitis_contact, class: 'Bookings::Gitis::Contact' do
    firstname { "Test" }
    sequence(:lastname) { |n| "User#{n}" }
    sequence(:emailaddress1) { |n| "testuser#{n}@testdomain.com" }
    phone { "01234 567890" }
    address1_line1 { "My Building" }
    address1_line2 { "Test Street" }
    address1_city { "Test Town" }
    address1_stateorprovince { "Test County" }
    address1_postalcode { "MA1 1AM" }
  end
end
