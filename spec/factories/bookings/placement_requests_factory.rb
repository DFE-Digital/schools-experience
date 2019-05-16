FactoryBot.define do
  factory :bookings_placement_request, class: 'Bookings::PlacementRequest' do
    objectives { "I want to be a teacher" }
    degree_stage { "Final year" }
    degree_subject { "Biology" }
    teaching_stage { "It’s just an idea" }
    subject_first_choice { "Mathematics" }
    subject_second_choice { "English" }
    has_dbs_check { false }
    availability { "Every second Thursday" }

    before(:create) do |bpr|
      bpr.urn = create(:bookings_school).urn
    end
  end
end
