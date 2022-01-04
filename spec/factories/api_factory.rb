FactoryBot.define do
  factory :api_schools_experience_sign_up, class: GetIntoTeachingApiClient::SchoolsExperienceSignUp do
    candidate_id { SecureRandom.uuid }
    master_id { nil }
    merged { false }
    email { "email@address.com" }
    telephone { "111111111" }
    address_line1 { "3 Main Street" }
    address_line2 { "Botchergate" }
    address_line3 { "" }
    address_city { "Carlisle" }
    address_state_or_province { "Cumbria" }
    address_postcode { "TE7 1NG" }
    has_dbs_certificate { nil }
    preferred_teaching_subject_id { '04fc5f49-887b-4ac6-82ea-4278e9f3a9c1' }
    secondary_preferred_teaching_subject_id { '686ba354-2a91-430b-affa-68b4e1fdffc0' }
    accepted_policy_id { SecureRandom.uuid }

    trait :merged do
      master_id { SecureRandom.uuid }
      merged { true }
    end

    factory :api_schools_experience_sign_up_with_name do
      sequence(:first_name) { |i| "First#{i}" }
      sequence(:last_name) { |i| "Last#{i}" }
      full_name { "#{first_name} #{last_name}" }
    end
  end

  factory :api_lookup_item, class: GetIntoTeachingApiClient::LookupItem do
    id { SecureRandom.uuid }
    sequence(:value) { |i| "value-#{i}" }
  end

  factory :api_privacy_policy, class: GetIntoTeachingApiClient::PrivacyPolicy do
    id { SecureRandom.uuid }
    text { "policy text" }
  end

  factory :api_teaching_subject, class: GetIntoTeachingApiClient::LookupItem do
    id { SecureRandom.uuid }
    sequence(:value) { |i| "Gitis Subject #{i}" }
  end
end
