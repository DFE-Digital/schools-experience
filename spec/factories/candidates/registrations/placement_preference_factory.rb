FactoryBot.define do
  factory :placement_preference, class: Candidates::Registrations::PlacementPreference do
    urn { 11048 }
    availability { 'Every second Friday' }
    objectives { 'Become a teacher' }
  end
end
