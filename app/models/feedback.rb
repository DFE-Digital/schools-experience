class Feedback < ApplicationRecord
  enum rating: %i(
    very_satisfied
    satisfied
    neither_satisfied_or_dissatisfied
    dissatisfied
    very_dissatisfied
  )

  REASON_REQUIRING_EXPLANATION = :something_else

  validates :reason_for_using_service, presence: true
  validates :rating, presence: true
  validates :reason_for_using_service_explanation,
    presence: true, if: -> { requires_explanation? reason_for_using_service }

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
