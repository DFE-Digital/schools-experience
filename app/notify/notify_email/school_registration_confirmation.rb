class NotifyEmail::SchoolRegistrationConfirmation < Notify
  attr_accessor :school_name,
    :school_admin_name,
    :school_experience_profile_link,
    :school_experience_dashboard_link

  def initialize(
    to:,
    school_name:,
    school_admin_name:,
    school_experience_profile_link:,
    school_experience_dashboard_link:
  )

    self.school_name = school_name
    self.school_admin_name = school_admin_name
    self.school_experience_profile_link = school_experience_profile_link
    self.school_experience_dashboard_link = school_experience_dashboard_link
    super(to: to)
  end

private

  def template_id
    '1b805620-1910-40b0-afe4-4ce9e5deebbf'
  end

  def personalisation
    {
      school_name: @school_name,
      school_admin_name: @school_admin_name,
      school_experience_profile_link: @school_experience_profile_link,
      school_experience_dashboard_link: @school_experience_dashboard_link
    }
  end
end
