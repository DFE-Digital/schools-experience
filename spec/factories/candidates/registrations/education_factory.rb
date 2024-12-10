FactoryBot.define do
  factory :education, class: 'Candidates::Registrations::Education' do
    urn { 11_048 }
    degree_stage { "Other" }
    degree_stage_explaination { "Khan academy, level 3" }
    degree_subject { "Biological sciences" }
  end
end
