FactoryBot.define do
  factory :candidate_experience_schedule, class: 'Schools::OnBoarding::CandidateExperienceSchedule' do
    start_time { '8:15am' }
    end_time { '4:30pm' }
    times_flexible { true }
    times_flexible_details { 'We are very accommodating' }

    trait :without_flexible_times do
      times_flexible { false }
      times_flexible_details { nil }
    end
  end
end
