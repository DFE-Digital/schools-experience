require 'csv'

class Bookings::SchoolSync
  BATCH_SIZE = 1000

  attr_accessor :email_override

  def initialize(email_override: nil)
    self.email_override = email_override
  end

  def sync
    if sync_disabled?
      Rails.logger.warn("GIAS sync attempted but disabled")
      return
    end

    import_and_update
  end

  # import any school records that aren't currently in our db
  def import_all
    data_in_batches do |batch|
      Bookings::Data::SchoolMassImporter.new(batch, email_override).import
    end
  end

  # update any school records that differ from edubase source
  def update_all
    data_in_batches do |batch|
      Bookings::Data::SchoolUpdater.new(batch).update
    end
  end

private

  def import_and_update
    import_all
    update_all
  end

  def sync_disabled?
    disabled = ENV.fetch('GIAS_SYNC_DISABLED') { false }
    disabled.to_s.in?(%w[1 true yes])
  end

  def gias_data_file
    Bookings::Data::GiasDataFile.new.path
  end

  def data_in_batches
    rows = []
    CSV.foreach(gias_data_file, headers: true, encoding: "ISO-8859-1:UTF-8") do |row|
      rows << row

      if rows.length >= BATCH_SIZE
        yield rows
        rows = []
      end
    end

    yield rows if rows.any?

    true
  end
end
