class Feedback < ApplicationRecord
  enum rating: {
    very_satisfied: 0,
    satisfied: 1,
    neither_satisfied_or_dissatisfied: 2,
    dissatisfied: 3,
    very_dissatisfied: 4
  }

  REASON_REQUIRING_EXPLANATION = :something_else

  validates :reason_for_using_service, presence: true
  validates :rating, presence: true
  validates :reason_for_using_service_explanation,
    presence: true, if: -> { requires_explanation? reason_for_using_service }
  validates :successful_visit, inclusion: [true, false]
  validates :unsuccessful_visit_explanation, presence: true, if: -> { successful_visit == false }

  def reasons_for_using_service
    self.class.reason_for_using_services.keys.map(&:to_sym)
  end

  def requires_explanation?(reason)
    reason.to_s == REASON_REQUIRING_EXPLANATION.to_s
  end

  def ratings
    self.class.ratings.keys.map(&:to_sym)
  end
end
