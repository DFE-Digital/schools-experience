class NotifyEmail::CandidateRequestCancellation < Notify
  attr_accessor :school_name, :candidate_name, :placement_start_date, :placement_finish_date

  def initialize(to:, school_name:, candidate_name:, placement_start_date:, placement_finish_date:)
    self.school_name    = school_name
    self.candidate_name = candidate_name
    self.placement_start_date     = placement_start_date
    self.placement_finish_date    = placement_finish_date
    super(to: to)
  end

private

  def template_id
    '17e87d47-afe9-477d-969d-8a4ab67280f3'
  end

  def personalisation
    {
      school_name: @school_name,
      candidate_name: @candidate_name,
      placement_start_date: @placement_start_date,
      placement_finish_date: @placement_finish_date
    }
  end
end
