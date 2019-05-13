FactoryBot.define do
  factory :experience_outline, class: Schools::OnBoarding::ExperienceOutline do
    candidate_experience { 'Mostly teaching' }
    provides_teacher_training { true }
    teacher_training_details { 'We offer teach training in house' }
    teacher_training_url { 'https://example.com' }
  end
end
