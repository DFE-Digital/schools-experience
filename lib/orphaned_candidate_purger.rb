# All personal candidate information is stored in the CRM
# contact entity. Occasionally, the contacts in the CRM will
# be deleted (if they have not seen activity in a long time).
# This can result in orphaned candidates in the application, where
# the gitis_uuid foreign key no longer points to a contact in the CRM.
# To keep the two datasets consistent we purge orphaned candidates
# from the School Exepreience database.
class OrphanedCandidatePurger
  BATCH_SIZE = 100

  def initialize(dry_run: true)
    @dry_run = dry_run
  end

  def purge!
    orphaned_candidates = []
    batch_candidates do |candidates|
      contact_fetcher.assign_to_models(candidates)
      orphaned_candidates += candidates.select(&:orphaned?)
    end

    if @dry_run
      Rails.logger.info("Orphaned candidates", orphaned_candidates)
    else
      Bookings::Candidate.destroy(orphaned_candidates.map(&:id))
    end
  end

private

  # Batch candidates ignoring those recently created in case
  # they haven't been pushed to the CRM yet.
  def batch_candidates
    Bookings::Candidate
      .where("created_at < ?", 1.day.ago)
      .find_in_batches(batch_size: BATCH_SIZE) do |candidates|
        yield(candidates)
      end
  end

  def contact_fetcher
    @contact_fetcher ||= Bookings::Gitis::ContactFetcher.new
  end
end
