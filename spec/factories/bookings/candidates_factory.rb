FactoryBot.define do
  factory :candidate, class: 'Bookings::Candidate' do
    gitis_uuid { SecureRandom.uuid }

    trait :confirmed do
      confirmed_at { 5.minutes.ago }
    end

    trait :with_gitis_contact do
      gitis_contact { build(:gitis_contact, :persisted) }
      gitis_uuid { gitis_contact.id }
    end
  end
end
