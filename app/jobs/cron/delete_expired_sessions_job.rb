# Expiry is enforced when reading, so this only reclaims space. Deletes in
# batches to keep each statement short.
class Cron::DeleteExpiredSessionsJob < ApplicationJob
  BATCH_SIZE = 1_000

  def perform
    [CandidateRegistration, BrowserSession].each do |model|
      loop do
        deleted = model.where(id: model.expired.limit(BATCH_SIZE).select(:id)).delete_all
        break if deleted < BATCH_SIZE
      end
    end
  end
end
