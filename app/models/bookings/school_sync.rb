class Bookings::SchoolSync
  FILE_LOCATION = Rails.root.join('tmp', 'edubase.csv').freeze

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
  ensure
    Rails.logger.debug("Deleting edubase data")
    File.delete(FILE_LOCATION)
  end

  def sync_disabled?
    disabled = ENV.fetch('GIAS_SYNC_DISABLED') { false }
    disabled.to_s.in?(%w(1 true yes))
  end

  # import any school records that aren't currently in our db
  def import_all
    SchoolMassImporter.new(data, email_override).import
  end

  # update any school records that differ from edubase source
  def update_all
    SchoolUpdater.new(data).update
  end

  def data
    download unless File.exist?(FILE_LOCATION)

    @data ||= CSV.parse(
      File.read(FILE_LOCATION).scrub,
      headers: true
    )
  end

  def download
    Rails.logger.debug("Downloading latest edubase data")
    date = Date.today.strftime('%Y%m%d')
    url = "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{date}.csv"
    File.open(FILE_LOCATION, 'wb') { |f| f.write(Net::HTTP.get(URI.parse(url))) }
  end
end
