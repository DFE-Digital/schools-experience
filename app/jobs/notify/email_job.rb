class Notify::EmailJob < Notify::BaseJob
  def perform(to:, template_id:, personalisation_json:)
    NotifyService.instance.send_email \
      template_id: template_id,
      email_address: to,
      personalisation: parse(personalisation_json)
  rescue Notifications::Client::ServerError => e
    alert_monitoring e
    raise RetryableError, e.message
  end
end
