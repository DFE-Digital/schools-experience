class Notify
  attr_accessor :notify_client, :to

  API_KEY = ENV['NOTIFY_API_KEY'].presence || Rails.application.credentials[:notify_api_key].freeze

  class RetryableError < ArgumentError; end

  class << self
    def notification_class
      Rails.application.config.x.notify_client.presence || Notifications::Client
    end
  end

  def initialize(to:)
    self.to = to
    self.notify_client = self.class.notification_class.new(API_KEY)
  end

  def despatch!
    begin
      notify_client.send_email(
        template_id: template_id,
        email_address: to,
        personalisation: personalisation
      )
    rescue Notifications::Client::ServerError => e
      raise RetryableError, e.message
    end
  end

  def despatch_later!
    NotifyJob.perform_later(self)
  end

private

  def template_id
    fail 'Not implemented'
  end

  def personalisation
    fail 'Not implemented'
  end
end
