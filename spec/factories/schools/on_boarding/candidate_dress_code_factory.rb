FactoryBot.define do
  factory :candidate_dress_code, class: 'Schools::OnBoarding::CandidateDressCode' do
    business_dress { true }
    cover_up_tattoos { true }
    remove_piercings { true }
    smart_casual { true }
    other_dress_requirements { true }
    other_dress_requirements_detail { 'Must have nice hat' }
  end
end
