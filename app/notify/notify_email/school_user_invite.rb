class NotifyEmail::SchoolUserInvite < NotifyDespatchers::Email
  def initialize(
    to:
  )
    super(to: to)
  end

private

  def template_id
    '8ac4d9f9-f51d-4c3b-9cc7-fd59751ece3d'
  end

  def personalisation
    {}
  end
end
