FactoryBot.define do
  factory :gitis_contact, class: 'Bookings::Gitis::Contact' do
    firstname { "Test" }
    sequence(:lastname) { |n| "User#{n}"}
    sequence(:email) { |n| "testuser#{n}@testdomain.com" }
    phone { "01234 567890" }
    building { "My Building" }
    street { "Test Street" }
    town_or_city { "Test Town" }
    county { "Test County" }
    postcode { "MA1 1AM" }
  end
end
