FactoryBot.define do
  factory :candidate_session_token, class: 'Bookings::CandidateSessionToken' do
    association :candidate, factory: :candidate

    trait :expired do
      expired_at { 5.minutes.ago }
    end

    trait :auto_expired do
      created_at { Time.zone.now - 1.minute - Bookings::CandidateSessionToken::AUTO_EXPIRE }
    end
  end
end
