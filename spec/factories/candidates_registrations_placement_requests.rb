FactoryBot.define do
  factory :candidates_registrations_placement_request, class: 'Candidates::Registrations::PlacementRequest' do
    date_start { "" }
    date_end { "" }
    objectives { "" }
    access_needs { "" }
    access_needs_details { "" }
    urn { "" }
    degree_stage { "" }
    degree_stage_explanination { "" }
    degree_subject { "" }
    teaching_stage { "" }
    subject_first_choice { "" }
    subject_second_choice { "" }
    has_dbs_check { false }
  end
end
