class NotifyEmail::ClosedOnboardedSchoolsSummary < NotifyDespatchers::Email
  attr_accessor :closed_onboarded_schools

  def initialize(to:, closed_onboarded_schools:)
    self.closed_onboarded_schools = closed_onboarded_schools

    super(to: to)
  end

private

  def template_id
    "a9547f2d-adb2-4cff-b9df-f2afc1ccbc66"
  end

  def personalisation
    {
      closed_onboarded_schools: closed_onboarded_schools,
    }
  end
end
