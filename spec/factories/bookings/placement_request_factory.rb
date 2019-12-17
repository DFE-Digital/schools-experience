FactoryBot.define do
  factory :placement_request, class: Bookings::PlacementRequest do
    association \
      :school,
      :with_profile,
      :with_subjects,
      factory: :bookings_school,
      urn: 11048,
      subject_count: 2

    association :candidate

    after :build do |placement_request|
      placement_request.subject_first_choice = placement_request.school.subjects.first.name
      placement_request.subject_second_choice = placement_request.school.subjects.second&.name || "I don't have a second subject"
      placement_request.urn = placement_request.school.urn
    end

    has_dbs_check { true }
    availability { 'Every second Friday' }
    objectives { 'Become a teacher' }
    degree_stage { "I don't have a degree and am not studying for one" }
    degree_stage_explaination { nil }
    degree_subject { "Not applicable" }
    teaching_stage { "I’m very sure and think I’ll apply" }

    # FIXME change this to cancelled_by_candidate
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

    trait :booked do
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

    trait :viewed do
      after :create, &:viewed!
    end

    trait :with_a_fixed_date do
      availability { nil }
      association :placement_date, factory: :bookings_placement_date
    end
  end
end
