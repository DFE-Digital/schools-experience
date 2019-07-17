FactoryBot.define do
  factory :candidates_feedback, class: Candidates::Feedback do
    reason_for_using_service { 'something_else' }
    reason_for_using_service_explanation { 'testing the software' }
    rating { 'very_satisfied' }
    improvements { "keep up the good work" }
  end
end
