class NotifyEmail::SchoolRequestCancellation < NotifyDespatchers::Email
  attr_accessor :school_name,
    :candidate_name,
    :cancellation_reasons,
    :requested_on,
    :placement_request_url

  def initialize(
    to:,
    school_name:,
    candidate_name:,
    cancellation_reasons:,
    requested_on:,
    placement_request_url:
  )

    self.school_name           = school_name
    self.candidate_name        = candidate_name
    self.cancellation_reasons  = cancellation_reasons
    self.requested_on          = requested_on
    self.placement_request_url = placement_request_url
    super(to: to)
  end

private

  def template_id
    '1d2b44bc-9d73-4839-b06b-41f35012c14d'
  end

  def personalisation
    {
      school_name: school_name,
      candidate_name: candidate_name,
      cancellation_reasons: cancellation_reasons,
      requested_on: requested_on,
      placement_request_url: placement_request_url
    }
  end
end
