class NotifyEmail::SchoolRegistrationConfirmation < Notify
  attr_accessor :school_name,
    :school_experience_profile_link,
    :school_experience_dashboard_link

  def initialize(
    to:,
    school_experience_profile_link:,
    school_experience_dashboard_link:
  )

    self.school_experience_profile_link = school_experience_profile_link
    self.school_experience_dashboard_link = school_experience_dashboard_link
    super(to: to)
  end

private

  def template_id
    '9b32a2f9-47b7-4069-897b-5ce637c5d5ba'
  end

  def personalisation
    {
      school_experience_profile_link: school_experience_profile_link,
      school_experience_dashboard_link: school_experience_dashboard_link
    }
  end
end
