class Notify::BaseNotifyJob < ApplicationJob
  class RetryableError < ArgumentError; end

  retry_on RetryableError, wait: A_DECENT_AMOUNT_LONGER, attempts: 7

  queue_as :default

  def perform
    raise NotImplementedError, 'You must implement the perform method'
  end

private

  def parse(personalisation_json)
    JSON.parse(personalisation_json).symbolize_keys
  end

  def alert_monitoring(exception)
    Sentry.capture_exception exception
  end
end
