class NotifyEmail::CandidateRequestCancellation < Notify
  attr_accessor :school_name, :requested_availability, :school_search_url

  def initialize(to:, school_name:, requested_availability:, school_search_url:)
    self.school_name            = school_name
    self.requested_availability = requested_availability
    self.school_search_url      = school_search_url
    super(to: to)
  end

private

  def template_id
    '86b06712-cb58-4cc7-82a1-3748cc9ad671'
  end

  def personalisation
    {
      school_name: school_name,
      requested_availability: requested_availability,
      school_search_url: school_search_url
    }
  end
end
