FactoryBot.define do
  factory :schools_feedback, class: Schools::Feedback do
    reason_for_using_service { 'something_else' }
    reason_for_using_service_explanation { 'testing the software' }
    rating { 'very_satisfied' }
    improvements { "keep up the good work" }
  end
end
