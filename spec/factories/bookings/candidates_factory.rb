FactoryBot.define do
  factory :candidate, class: 'Bookings::Candidate' do
    gitis_uuid { SecureRandom.uuid }

    trait :confirmed do
      confirmed_at { 5.minutes.ago }
    end

    trait :with_api_contact do
      gitis_contact { build(:api_schools_experience_sign_up) }
      gitis_uuid { gitis_contact.candidate_id }
    end
  end
end
