class NotifyJob < ApplicationJob
  class RetryableError < ArgumentError; end

  retry_on RetryableError, wait: A_DECENT_AMOUNT_LONGER, attempts: 7

  queue_as :default

  def perform(to:, template_id:, personalisation_json:)
    NotifyService.instance.send_email \
      template_id: template_id,
      email_address: to,
      personalisation: parse(personalisation_json)
  rescue Notifications::Client::ServerError => e
    alert_monitoring e
    raise RetryableError, e.message
  end

private

  def parse(personalisation_json)
    JSON.parse(personalisation_json).symbolize_keys
  end

  def alert_monitoring(exception)
    ExceptionNotifier.notify_exception exception
    Raven.capture_exception exception
  end
end
