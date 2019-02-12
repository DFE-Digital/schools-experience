class ApplicationJob < ActiveJob::Base
  # This does not supply a block for handling failure, this should be left to
  # cascade up to DelayJob which will deal with notifying in the event of
  # failure
  retry_on(StandardError, attempts: 3, wait: :exponentially_longer)
end
