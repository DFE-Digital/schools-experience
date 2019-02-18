class Notify
  attr_accessor :notify_client, :to

  API_KEY = Rails.application.credentials[:notify_api_key].freeze

  class NotifyAPIKeyMissing < ArgumentError; end

  def initialize(to:)
    self.to = to
    if API_KEY.present?
      self.notify_client = Notifications::Client.new(API_KEY)
    else
      fail(NotifyAPIKeyMissing, "Notify API key is missing")
    end
  end

  def despatch!
    notify_client.send_email(
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
