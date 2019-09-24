class NotifyEmail::CandidateBookingCancellation < Notify
  attr_accessor :school_name, :placement_start_date_with_duration, :school_search_url

  def initialize(to:, school_name:, placement_start_date_with_duration:, school_search_url:)
    self.school_name                        = school_name
    self.placement_start_date_with_duration = placement_start_date_with_duration
    self.school_search_url                  = school_search_url
    super(to: to)
  end

private

  def template_id
    'af2311b2-7b7e-4342-b1da-bba957273b3e'
  end

  def personalisation
    {
      school_name: school_name,
      placement_start_date_with_duration: placement_start_date_with_duration,
      school_search_url: school_search_url
    }
  end
end
