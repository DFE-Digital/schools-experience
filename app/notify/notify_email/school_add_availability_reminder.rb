class NotifyEmail::SchoolAddAvailabilityReminder < NotifyDespatchers::Email
  def initialize(
    to:
  )
    super(to: to)
  end

private

  def template_id
    'eee3d861-3365-40ff-a178-80516f771024'
  end

  def personalisation
    {}
  end
end
