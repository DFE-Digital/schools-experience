FactoryBot.define do
  factory :bookings_booking, class: 'Bookings::Booking' do
    association :bookings_school, factory: :bookings_school
    association :bookings_subject, factory: :bookings_subject

    association :bookings_placement_request,
      factory: :bookings_placement_request,
      created_at: Time.new(2019, 2, 8, 15, 37)

    date { 2.months.from_now }

    trait :accepted do
      accepted_at { 5.minutes.ago }
    end

    trait :with_existing_subject do
      before(:create) do |bb|
        bb.bookings_subject = bb.bookings_school.subjects.first
      end
    end

    trait :with_more_details_added do
      contact_name { 'William MacDougal' }
      contact_email { 'gcw@springfield.edu' }
      contact_number { '01234 456 245' }
      location { 'Come to reception in the East building' }
    end
  end
end
