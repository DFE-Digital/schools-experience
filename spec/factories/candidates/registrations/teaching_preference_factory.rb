FactoryBot.define do
  factory :teaching_preference, class: Candidates::Registrations::TeachingPreference do
    transient do
      registration_session { FactoryBot.build :flattened_registration_session }
    end

    initialize_with do
      new registration_session: registration_session
    end

    teaching_stage { "I’m very sure and think I’ll apply" }
    subject_first_choice { "Astronomy" }
    subject_second_choice { "History" }
  end
end
