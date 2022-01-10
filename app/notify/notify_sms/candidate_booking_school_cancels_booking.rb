class NotifySms::CandidateBookingSchoolCancelsBooking < NotifyDespatchers::Sms
  attr_accessor \
    :school_name,
    :dates_requested

  def initialize(
    to:,
    school_name:,
    dates_requested:
  )

    self.school_name = school_name
    self.dates_requested = dates_requested

    super(to: to)
  end

private

  def template_id
    'f4bbf2dc-5ebf-4723-8560-1266608e558d'
  end

  def personalisation
    {
      school_name: school_name,
      dates_requested: dates_requested
    }
  end
end
