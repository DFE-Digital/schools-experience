FactoryBot.define do
  factory :teaching_preference, class: Candidates::Registrations::TeachingPreference do
    transient do
      school { FactoryBot.create :bookings_school }
    end

    initialize_with do
      new school: school
    end

    urn { 11048 }
    teaching_stage { "I’m very sure and think I’ll apply" }
    subject_first_choice { "Astronomy" }
    subject_second_choice { "History" }
  end
end
