class NotifySms::CandidateBookingReminder < NotifyDespatchers::Sms
  attr_accessor \
    :school_name,
    :time_until_booking

  def initialize(
    to:,
    time_until_booking:,
    school_name:
  )

    self.time_until_booking = time_until_booking
    self.school_name = school_name

    super(to: to)
  end

private

  def template_id
    '4bcb7dc7-cf1d-47d0-8773-1183c315d284'
  end

  def personalisation
    {
      time_until_booking: time_until_booking,
      school_name: school_name
    }
  end
end
