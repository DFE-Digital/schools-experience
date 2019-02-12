class Notify
  attr_accessor :notify_client, :to

  API_KEY = Rails.application.credentials[:notify_api_key]

  def initialize(to:)
    self.to = to
    @notify_client = Notifications::Client.new(API_KEY)
  end

  def despatch!
    @notify_client.send_email(
      template_id: template_id,
      email_address: @to,
      personalisation: personalisation
    )
  end

private

  def template_id
    fail 'Not implemented'
  end

  def personalisation
    fail 'Not implemented'
  end
end
