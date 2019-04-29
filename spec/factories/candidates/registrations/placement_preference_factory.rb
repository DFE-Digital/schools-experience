FactoryBot.define do
  factory :placement_preference, class: Candidates::Registrations::PlacementPreference do
    availability { 'Every second Friday' }
    objectives { 'Become a teacher' }
  end
end
