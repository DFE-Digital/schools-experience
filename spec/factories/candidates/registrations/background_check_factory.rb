FactoryBot.define do
  factory :background_check, class: Candidates::Registrations::BackgroundCheck do
    has_dbs_check { true }
  end
end
