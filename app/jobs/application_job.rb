class ApplicationJob < ActiveJob::Base
  # This does not supply a block for handling failure, this should be left to
  # cascade up to DelayJob which will deal with notifying in the event of
  # failure
  retry_on(StandardError, attempts: 3, wait: :exponentially_longer)

  # Retry | Backoff
  # 1     | 108 seconds
  # 2     | 24 minutes
  # 3     | 2 hours 15 minutes
  # 4     | 8 hours 40 minutes
  A_DECENT_AMOUNT_LONGER = ->(executions) { ((executions + 1)**6) * 2 }
end
