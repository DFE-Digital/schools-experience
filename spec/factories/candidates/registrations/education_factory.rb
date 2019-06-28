FactoryBot.define do
  factory :education, class: Candidates::Registrations::Education do
    degree_stage { "Other" }
    degree_stage_explaination { "Khan academy, level 3" }
    degree_subject { "Bioscience" }
  end
end
