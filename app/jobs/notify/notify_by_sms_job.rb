class Notify::NotifyBySmsJob < Notify::BaseNotifyJob
  def perform(to:, template_id:, personalisation_json:)
    NotifyService.instance.send_sms \
      template_id: template_id,
      phone_number: to,
      personalisation: parse(personalisation_json)
  rescue Notifications::Client::ServerError => e
    alert_monitoring e
    raise RetryableError, e.message
  end
end
