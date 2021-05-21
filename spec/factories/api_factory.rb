FactoryBot.define do
  factory :api_schools_experience_sign_up, class: GetIntoTeachingApiClient::SchoolsExperienceSignUp do
    candidate_id { SecureRandom.uuid }
    first_name { "First" }
    last_name { "Last" }
    email { "email@address.com" }
    secondary_email { "email2@address.com" }
    date_of_birth { Date.new(1987, 3, 12) }
    telephone { "111111111" }
    secondary_telephone { "222222222" }
    address_telephone { "333333333" }
    mobile_telephone { "444444444" }
    address_line1 { "3 Main Street" }
    address_line2 { "Botchergate" }
    address_line3 { "" }
    address_city { "Carlisle" }
    address_state_or_province { "Cumbria" }
    address_postcode { "TE7 1NG" }
    has_dbs_certificate { true }
    preferred_teaching_subject_id { SecureRandom.uuid }
    secondary_preferred_teaching_subject_id { SecureRandom.uuid }
    accepted_policy_id { SecureRandom.uuid }
  end

  factory :api_lookup_item, class: GetIntoTeachingApiClient::LookupItem do
    id { SecureRandom.uuid }
    value { "value-#{sequence(:value)}" }
  end

  factory :api_privacy_policy, class: GetIntoTeachingApiClient::PrivacyPolicy do
    id { SecureRandom.uuid }
    text { "policy text" }
  end
end
