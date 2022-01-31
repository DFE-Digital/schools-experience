FactoryBot.define do
  factory :placement_preference, class: Candidates::Registrations::PlacementPreference do
    urn { 11_048 }
    objectives { 'Become a teacher' }
  end
end
