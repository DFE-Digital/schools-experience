class Notify
  attr_accessor :notify_client, :to

  API_KEY = Rails.application.credentials[:notify_api_key].freeze

  class APIKeyMissing < ArgumentError; end
  class RetryableError < ArgumentError; end

  def initialize(to:)
    self.to = to
    if API_KEY.present?
      self.notify_client = Notifications::Client.new(API_KEY)
    else
      fail(APIKeyMissing, "Notify API key is missing")
    end
  end

  def despatch!
    begin
      notify_client.send_email(
        template_id: template_id,
        email_address: @to,
        personalisation: personalisation
      )
    rescue Notifications::Client::ServerError => e
      raise RetryableError, e.message
    end
  end

private

  def template_id
    fail 'Not implemented'
  end

  def personalisation
    fail 'Not implemented'
  end
end
