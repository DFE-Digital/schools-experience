class Notify
  attr_accessor :notify_client, :to

  API_KEY = ENV['NOTIFY_API_KEY'].presence || Rails.application.credentials[:notify_api_key].freeze

  class RetryableError < ArgumentError; end

  class << self
    def notification_class
      Thread.current[:notification_class] || Notifications::Client
    end

    def notification_class=(klass)
      Thread.current[:notification_class] = klass
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
