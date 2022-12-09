FactoryBot.define do
  factory :candidate, class: 'Bookings::Candidate' do
    gitis_uuid { SecureRandom.uuid }

    trait :confirmed do
      confirmed_at { 5.minutes.ago }
    end

    trait :with_api_contact do
      gitis_contact { build(:api_schools_experience_sign_up_with_name) }
      gitis_uuid { gitis_contact.candidate_id }
    end

    trait :with_missing_api_contact do
      gitis_contact { Bookings::Gitis::MissingContact.new(gitis_uuid) }
    end

    trait :with_attended_booking do
      after :create do |candidate|
        FactoryBot.create(:placement_request, :with_attended_booking, candidate: candidate)
      end
    end
  end

  factory :recurring_candidate, class: 'Bookings::Candidate' do
    transient do
      school { nil }
    end

    gitis_uuid { SecureRandom.uuid }

    after :create do |candidate, evaluator|
      school = evaluator.school || FactoryBot.create(:bookings_school)

      FactoryBot.create(:placement_request, :with_attended_booking, candidate: candidate, school: school)
      FactoryBot.create(:placement_request, candidate: candidate, school: school)
    end
  end
end
