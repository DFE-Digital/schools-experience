class Notify::BaseJob < ApplicationJob
  class RetryableError < ArgumentError; end

  # Outside production we authenticate to GOV.UK Notify with a team-only (test)
  # or trial-mode API key, which rejects recipients that are not on the
  # service's team/allow-list with a 400. In review apps candidates enter
  # arbitrary addresses, so this is expected noise rather than a fault. These
  # are the stable message fragments Notify returns for that restriction.
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

  # Swallow the Notify recipient-restriction 400 outside production (no retry,
  # no alert). In production the same error indicates a genuine problem and must
  # surface, and any other 400 surfaces everywhere so real bugs are not hidden.
  def handle_recipient_restriction_error(exception)
    raise exception if Rails.env.production? || !recipient_restriction_error?(exception)

    Rails.logger.warn \
      "Skipping Notify delivery outside production: #{exception.message}"
  end

  def recipient_restriction_error?(exception)
    message = exception.message.to_s.downcase
    RECIPIENT_RESTRICTION_MESSAGES.any? { |fragment| message.include?(fragment.downcase) }
  end
end
