FactoryBot.define do
  factory :placement_request, class: Bookings::PlacementRequest do
    association :school,
      :with_subjects, factory: :bookings_school, urn: 11048, subject_count: 2

    after :build do |placement_request|
      placement_request.subject_first_choice = placement_request.school.subjects.first.name
      placement_request.subject_second_choice = placement_request.school.subjects.second.name
      placement_request.urn = placement_request.school.urn
    end

    has_dbs_check { true }
    availability { 'Every second Friday' }
    objectives { 'Become a teacher' }
    degree_stage { "I don't have a degree and am not studying for one" }
    degree_stage_explaination { nil }
    degree_subject { "Not applicable" }
    teaching_stage { "I’m very sure and think I’ll apply" }

    trait :cancelled do
      before :create do |placement_request|
        placement_request.cancellation = \
          FactoryBot.build :cancellation, placement_request: placement_request
      end
    end
  end
end
