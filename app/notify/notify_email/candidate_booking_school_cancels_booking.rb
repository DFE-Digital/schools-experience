class NotifyEmail::CandidateBookingSchoolCancelsBooking < Notify
  attr_accessor :candidate_name,
    :school_name,
    :dates_requested,
    :rejection_reasons,
    :extra_details,
    :school_search_url

  def initialize(to:, candidate_name:, school_name:, dates_requested:, rejection_reasons:, extra_details:, school_search_url:)
    self.candidate_name    = candidate_name
    self.school_name       = school_name
    self.dates_requested   = dates_requested
    self.rejection_reasons = rejection_reasons
    self.extra_details     = extra_details
    self.school_search_url = school_search_url

    super(to: to)
  end

private

  def template_id
    'd7e4fd68-0f01-4a9e-96f1-62a8a77a9de1'
  end

  def personalisation
    {
      candidate_name: candidate_name,
      school_name: school_name,
      dates_requested: dates_requested,
      rejection_reasons: rejection_reasons,
      extra_details: extra_details,
      school_search_url: school_search_url
    }
  end
end
