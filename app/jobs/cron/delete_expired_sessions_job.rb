# Expiry is enforced when reading, so this only reclaims space. Deletes in
# batches to keep each statement short.
class Cron::DeleteExpiredSessionsJob < ApplicationJob
  BATCH_SIZE = 1_000

  def perform
    [CandidateRegistration, BrowserSession].each do |model|
      model.expired.in_batches(of: BATCH_SIZE, &:delete_all)
    end
  end
end
