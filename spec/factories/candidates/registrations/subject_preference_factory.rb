FactoryBot.define do
  factory :subject_preference, class: Candidates::Registrations::SubjectPreference do
    degree_stage { "I don't have a degree and am not studying for one" }
    degree_stage_explaination { nil }
    degree_subject { "Not applicable" }
    teaching_stage { "I’m very sure and think I’ll apply" }
    subject_first_choice { "Astronomy" }
    subject_second_choice { "History" }

    trait :with_degree_stage_other do
      degree_stage { "Other" }
      degree_stage_explaination { "Sabbatical" }
      degree_subject { "History" }
    end
  end
end
