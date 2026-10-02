class Notify::BaseJob < ApplicationJob
  class RetryableError < ArgumentError; end

  RECIPIENT_RESTRICTION_MESSAGES = [
    'team-only API key',
    'trial mode'
  ].freeze

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

  def handle_recipient_restriction_error(exception, template_id:)
    raise exception if Rails.env.production? || !recipient_restriction_error?(exception)

    Rails.logger.warn \
      "Skipping Notify delivery outside production " \
      "(job #{job_id}, template #{template_id}): #{exception.message}"
  end

  def recipient_restriction_error?(exception)
    message = exception.message.to_s.downcase
    RECIPIENT_RESTRICTION_MESSAGES.any? { |fragment| message.include?(fragment.downcase) }
  end
end
