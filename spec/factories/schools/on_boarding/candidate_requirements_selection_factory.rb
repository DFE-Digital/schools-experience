FactoryBot.define do
  factory :candidate_requirements_selection, class: 'Schools::OnBoarding::CandidateRequirementsSelection' do
    selected_requirements { %w[on_teacher_training_course has_or_working_towards_degree live_locally provide_photo_identification other] }
    maximum_distance_from_school { 8 }
    photo_identification_details { 'Make sure photo is clear' }
    other_details { 'Some other requirements' }
  end
end
