class Notify
  attr_accessor :notify_client, :email_address

  API_KEY = Rails.application.credentials[:notify_api_key]

  def initialize(email_address:)
    self.email_address = email_address
    @notify_client = Notifications::Client.new(API_KEY)
  end

  def despatch!
    @notify_client.send_email(
      template_id: template_id,
      email_address: @email_address,
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
