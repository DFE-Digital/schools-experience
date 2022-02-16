FactoryBot.define do
  factory :placement_request, class: Bookings::PlacementRequest do
    association \
      :school,
      :with_profile,
      :with_subjects,
      factory: :bookings_school,
      urn: 11_048,
      subject_count: 2

    association :candidate

    after :build do |placement_request|
      placement_request.subject_first_choice = placement_request.available_subject_choices.first
      placement_request.subject_second_choice = placement_request.available_subject_choices&.second || "I don't have a second subject"
      placement_request.urn = placement_request.school.urn
    end

    has_dbs_check { true }
    availability { 'Every second Friday' }
    objectives { 'Become a teacher' }
    degree_stage { "I don't have a degree and am not studying for one" }
    degree_stage_explaination { nil }
    degree_subject { "Not applicable" }
    teaching_stage { "I’m very sure and think I’ll apply" }
    experience_type { 'both' }

    # FIXME: change this to cancelled_by_candidate
    trait :cancelled do
      before :create do |placement_request|
        placement_request.candidate_cancellation = \
          FactoryBot.build :cancellation,
            :sent, placement_request: placement_request
      end
    end

    trait :with_viewed_candidate_cancellation do
      before :create do |placement_request|
        placement_request.candidate_cancellation = \
          FactoryBot.build :cancellation,
            :sent, :viewed, placement_request: placement_request
      end
    end

    trait :cancelled_by_school do
      before :create do |placement_request|
        placement_request.school_cancellation = \
          FactoryBot.build :cancellation,
            :sent, placement_request: placement_request, cancelled_by: 'school', rejection_category: :fully_booked
      end
    end

    trait :with_school_cancellation do
      before :create do |placement_request|
        placement_request.school_cancellation = \
          FactoryBot.build :cancellation,
            rejection_category: :fully_booked,
            placement_request: placement_request, cancelled_by: 'school'
      end
    end

    trait :with_incomplete_booking do
      after :create do |placement_request|
        FactoryBot.create \
          :bookings_booking,
          :with_existing_subject,
          bookings_school: placement_request.school,
          bookings_subject: placement_request.school.subjects.first,
          bookings_placement_request: placement_request,
          bookings_placement_request_id: placement_request.id
      end
    end

    trait :booked do
      after :create do |placement_request|
        FactoryBot.create \
          :bookings_booking,
          :accepted,
          :with_existing_subject,
          :accepted,
          bookings_school: placement_request.school,
          bookings_placement_request: placement_request,
          bookings_placement_request_id: placement_request.id
      end
    end

    trait :with_attended_booking do
      after :create do |placement_request|
        FactoryBot.create \
          :bookings_booking,
          :with_existing_subject,
          :attended,
          bookings_school: placement_request.school,
          bookings_placement_request: placement_request,
          bookings_placement_request_id: placement_request.id
      end
    end

    trait :viewed do
      after :create, &:viewed!
    end

    trait :under_consideration do
      under_consideration_at { 5.minutes.ago }
    end

    trait :with_a_fixed_date do
      association \
        :school,
        :with_profile,
        :with_subjects,
        :with_fixed_availability_preference,
        factory: :bookings_school,
        urn: 11_048,
        subject_count: 2

      availability { nil }
      association :placement_date, factory: :bookings_placement_date
    end

    trait :with_a_fixed_date_in_the_recent_past do
      availability { nil }
      association :placement_date, :in_the_recent_past, factory: :bookings_placement_date
    end

    trait :with_a_fixed_date_in_the_past do
      availability { nil }
      association :placement_date, :in_the_past, factory: :bookings_placement_date
    end

    trait :virtual do
      experience_type { 'virtual' }
    end

    trait :inschool do
      experience_type { 'inschool' }
    end
  end
end
