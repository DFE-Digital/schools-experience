class NotifyEmail::CandidateRequestCancellation < Notify
  attr_accessor :school_name, :candidate_name, :requested_availability, :school_search_url

  def initialize(to:, school_name:, candidate_name:, requested_availability:, school_search_url:)
    self.school_name            = school_name
    self.candidate_name         = candidate_name
    self.requested_availability = requested_availability
    self.school_search_url      = school_search_url
    super(to: to)
  end

private

  def template_id
    '12370ef4-5146-4732-87c9-76f852b4bfa9'
  end

  def personalisation
    {
      school_name: school_name,
      candidate_name: candidate_name,
      requested_availability: requested_availability,
      school_search_url: school_search_url
    }
  end
end
