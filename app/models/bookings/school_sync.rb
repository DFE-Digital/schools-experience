require 'csv'

class Bookings::SchoolSync
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

private

  def import_and_update
    import_all
    update_all
  end

  def sync_disabled?
    disabled = ENV.fetch('GIAS_SYNC_DISABLED') { false }
    disabled.to_s.in?(%w(1 true yes))
  end

  # import any school records that aren't currently in our db
  def import_all
    Bookings::Data::SchoolMassImporter.new(data, email_override).import
  end

  # update any school records that differ from edubase source
  def update_all
    Bookings::Data::SchoolUpdater.new(data).update
  end

  def data
    gias_data_file = Bookings::Data::GiasDataFile.new.path

    @data ||= CSV.parse(
      File.read(gias_data_file).force_encoding('ISO-8859-1'),
      headers: true
    )
  end
end
