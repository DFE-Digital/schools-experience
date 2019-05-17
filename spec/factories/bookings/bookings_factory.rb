FactoryBot.define do
  factory :bookings_booking, class: 'Bookings::Booking' do
    association :bookings_school, factory: :bookings_school
    association :bookings_subject, factory: :bookings_subject

    association :bookings_placement_request,
      factory: :bookings_placement_request,
      created_at: Time.new(2019, 2, 8, 15, 37)

    trait :with_existing_subject do
      before(:create) do |bb|
        bb.bookings_subject = bb.bookings_school.subjects.first
      end
    end

    date { 2.months.from_now }
  end
end
