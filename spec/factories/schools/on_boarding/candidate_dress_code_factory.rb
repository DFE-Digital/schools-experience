FactoryBot.define do
  factory :candidate_dress_code, class: 'Schools::OnBoarding::CandidateDressCode' do
    selected_requirements { %w[business_dress cover_up_tattoos remove_piercings smart_casual other_dress_requirements] }
    other_dress_requirements_detail { 'Must have nice hat' }
  end
end
