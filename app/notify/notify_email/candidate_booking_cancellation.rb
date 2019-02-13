class NotifyEmail::CandidateBookingCancellation < Notify
  attr_accessor :school_name, :candidate_name, :start_date, :finish_date

  def initialize(to:, school_name:, candidate_name:, start_date:, finish_date:)
    self.school_name    = school_name
    self.candidate_name = candidate_name
    self.start_date     = start_date
    self.finish_date    = finish_date
    super(to: to)
  end

private

  def template_id
    'ec830a0d-d032-4d4b-a107-882d6f3b471f'
  end

  def personalisation
    {
      school_name: @school_name,
      candidate_name: @candidate_name,
      start_date: @start_date,
      finish_date: @finish_date
    }
  end
end
