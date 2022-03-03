FactoryBot.define do
  factory :candidate_experience_detail, class: 'Schools::OnBoarding::CandidateExperienceDetail' do
    parking_provided { true }
    parking_details { 'Plenty of spaces' }
    nearby_parking_details { nil }
    start_time { '8:15am' }
    end_time { '4:30pm' }
    times_flexible { true }
    times_flexible_details { 'We are very accommodating' }

    trait :without_parking do
      parking_provided { false }
      nearby_parking_details { 'Public car park across the street' }
    end

    trait :without_flexible_times do
      times_flexible { false }
      times_flexible_details { nil }
    end
  end
end
