class NotifyEmail::CandidateRequestRejection < Notify
  attr_accessor \
    :school_name,
    :candidate_name,
    :rejection_reasons,
    :extra_details,
    :dates_requested,
    :school_search_url

  def initialize(to:, school_name:, candidate_name:, rejection_reasons:, extra_details:, dates_requested:, school_search_url:)
    self.school_name       = school_name
    self.candidate_name    = candidate_name
    self.rejection_reasons = rejection_reasons
    self.extra_details     = extra_details
    self.dates_requested   = dates_requested
    self.school_search_url = school_search_url
    super(to: to)
  end

private

  def template_id
    '577100df-1dae-405e-8500-947b85edf76e'
  end

  def personalisation
    {
      school_name: school_name,
      candidate_name: candidate_name,
      rejection_reasons: rejection_reasons,
      extra_details: extra_details,
      dates_requested: dates_requested,
      school_search_url: school_search_url
    }
  end
end
