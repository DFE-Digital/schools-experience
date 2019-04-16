FactoryBot.define do
  factory :candidate_experience_detail, class: 'Schools::OnBoarding::CandidateExperienceDetail' do
    business_dress { true }
    cover_up_tattoos { true }
    remove_piercings { true }
    smart_casual { true }
    other_dress_requirements { true }
    other_dress_requirements_detail { 'Must have nice hat' }
    parking_provided { true }
    parking_details { 'Plenty of spaces' }
    nearby_parking_details { nil }
    disabled_facilities { false }
    disabled_facilities_details { '' }
    start_time { '8:15am' }
    end_time { '4:30pm' }
    times_flexible { true }
  end
end
