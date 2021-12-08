class NotifyService
  API_KEY = ENV['NOTIFY_API_KEY'].presence || Rails.application.credentials[:notify_api_key].freeze

  include Singleton

  attr_accessor :notification_class

  def initialize
    self.notification_class =
      Rails.application.config.x.notify_client.presence&.constantize ||
      Notifications::Client
  end

  def send_email(email_address:, template_id:, personalisation:)
    notify_client.send_email \
      template_id: template_id,
      email_address: email_address,
      personalisation: personalisation
  end

  def send_sms(phone_number:, template_id:, personalisation:)
    notify_client.send_sms \
      template_id: template_id,
      phone_number: phone_number,
      personalisation: personalisation
  end

private

  def notify_client
    notification_class.new API_KEY
  end
end
