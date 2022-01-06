class NotifySms::CandidateBookingConfirmation < NotifyDespatchers::Sms
  attr_accessor \
    :school_name,
    :dates_requested,
    :cancellation_url

  def initialize(
    to:,
    school_name:,
    dates_requested:,
    cancellation_url:
  )

    self.school_name = school_name
    self.dates_requested = dates_requested
    self.cancellation_url = cancellation_url

    super(to: to)
  end

private

  def template_id
    'c034e972-a9c6-4fae-924a-25ad8bf54031'
  end

  def personalisation
    {
      school_name: school_name,
      dates_requested: dates_requested,
      cancellation_url: cancellation_url
    }
  end
end
