FactoryBot.define do
  factory :background_check, class: Candidates::Registrations::BackgroundCheck do
    urn { 11_048 }
    has_dbs_check { true }
  end
end
