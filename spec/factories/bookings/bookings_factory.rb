FactoryBot.define do
  factory :bookings_booking, class: 'Bookings::Booking' do
    association :bookings_subject, factory: :bookings_subject

    association :bookings_placement_request,
      factory: :bookings_placement_request

    bookings_school { bookings_placement_request.school }
    contact_name { 'William MacDougal' }
    contact_email { 'gcw@springfield.edu' }
    contact_number { '01234 456 245' }
    experience_type { 'inschool' }

    date { 2.months.from_now }

    trait :virtual_experience do
      experience_type { 'virtual' }
    end

    trait :accepted do
      candidate_instructions { 'Report to reception on arrival' }
      accepted_at { 5.minutes.ago }
    end

    trait :attended do
      attended { true }
    end

    trait :unattended do
      attended { false }
    end

    trait :previous do
      to_create { |instance| instance.save!(validate: false) }
      date { 2.weeks.ago }
    end

    trait :with_existing_subject do
      before(:create) do |bb|
        bb.bookings_subject = \
          Bookings::Subject.find_by! \
            name: bb.bookings_placement_request.available_subject_choices.first
      end
    end

    trait :cancelled_by_candidate do
      after :create do |bb|
        bb.bookings_placement_request.create_candidate_cancellation! \
          attributes_for :cancellation, :sent, :cancelled_by_candidate
      end
    end

    trait :cancelled_by_school do
      after :create do |bb|
        bb.bookings_placement_request.create_school_cancellation! \
          attributes_for :cancellation, :sent, :cancelled_by_school
      end
    end

    trait :with_viewed_candidate_cancellation do
      cancelled_by_candidate
      after :create do |bb|
        bb.candidate_cancellation.viewed!
      end
    end
  end
end
