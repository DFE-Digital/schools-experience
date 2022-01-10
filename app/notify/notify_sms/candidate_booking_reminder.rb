class NotifySms::CandidateBookingReminder < NotifyDespatchers::Sms
  attr_accessor \
    :time_until_booking,
    :dates_requested,
    :cancellation_url

  def initialize(
    to:,
    time_until_booking:,
    dates_requested:,
    cancellation_url:
  )

    self.time_until_booking = time_until_booking
    self.dates_requested = dates_requested
    self.cancellation_url = cancellation_url

    super(to: to)
  end

private

  def template_id
    '10aa6a3b-bbe8-4e98-97b2-4409eef47496'
  end

  def personalisation
    {
      time_until_booking: time_until_booking,
      dates_requested: dates_requested,
      cancellation_url: cancellation_url
    }
  end
end
