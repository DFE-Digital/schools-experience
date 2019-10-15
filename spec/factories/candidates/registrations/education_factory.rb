FactoryBot.define do
  factory :education, class: Candidates::Registrations::Education do
    urn { 11048 }
    degree_stage { "Other" }
    degree_stage_explaination { "Khan academy, level 3" }
    degree_subject { "Bioscience" }
  end
end
