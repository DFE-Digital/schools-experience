class ApplicationJob < ActiveJob::Base
  # This does not supply a block for handling failure, this should be left to
  # cascade up to DelayJob which will deal with notifying in the event of
  # failure
  retry_on(StandardError, attempts: 3, wait: :exponentially_longer)

  RETRYS = [
    1.minute,
    10.minutes,
    1.hour,
    2.hours
  ].freeze

  MAX_RETRY = 4.hours

  A_DECENT_AMOUNT_LONGER = ->(executions) do
    RETRYS[executions - 1] || MAX_RETRY
  end
end
