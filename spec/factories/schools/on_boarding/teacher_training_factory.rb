FactoryBot.define do
  factory :teacher_training, class: 'Schools::OnBoarding::TeacherTraining' do
    provides_teacher_training { true }
    teacher_training_details { 'We offer teach training in house' }
    teacher_training_url { 'https://example.com' }
  end
end
