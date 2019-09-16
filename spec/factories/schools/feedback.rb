FactoryBot.define do
  factory :schools_feedback, class: Schools::Feedback do
    reason_for_using_service { 'something_else' }
    reason_for_using_service_explanation { 'testing the software' }
    rating { 'very_satisfied' }
    improvements { "keep up the good work" }
    successful_visit { false }
    unsuccessful_visit_explanation { "Hoping to leave angry feedback but site was too good" }
  end
end
