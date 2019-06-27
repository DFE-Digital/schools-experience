class NotifyEmail::CandidateBookingCancellation < Notify
  attr_accessor :school_name, :candidate_name, :placement_start_date_with_duration, :school_search_url

  def initialize(to:, school_name:, candidate_name:, placement_start_date_with_duration:, school_search_url:)
    self.school_name                        = school_name
    self.candidate_name                     = candidate_name
    self.placement_start_date_with_duration = placement_start_date_with_duration
    self.school_search_url                  = school_search_url
    super(to: to)
  end

private

  def template_id
    '12b5984b-be09-44fe-9f79-68aea6108f91'
  end

  def personalisation
    {
      school_name: school_name,
      candidate_name: candidate_name,
      placement_start_date_with_duration: placement_start_date_with_duration,
      school_search_url: school_search_url
    }
  end
end
