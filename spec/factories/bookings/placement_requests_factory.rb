FactoryBot.define do
  factory :bookings_placement_request, class: 'Bookings::PlacementRequest' do
    objectives { "I want to be a teacher" }
    degree_stage { "Final year" }
    degree_subject { "Bioscience" }
    teaching_stage { "It’s just an idea" }
    subject_first_choice { "Biology" }
    subject_second_choice { "Biology" }
    has_dbs_check { true }
    availability { "Every second Thursday" }
    association :school, factory: :bookings_school
    urn { 123456 }

    trait(:with_a_fixed_date) do
      availability { nil }
      association :placement_date, factory: :bookings_placement_date
    end
  end
end
