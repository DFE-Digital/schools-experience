FactoryBot.define do
  factory :availability_preference, class: Candidates::Registrations::AvailabilityPreference do
    urn { 11_048 }
    availability { 'Every second Friday' }
  end
end
