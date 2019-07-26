class Schools::Sync
  FILE_LOCATION = File.join('tmp', 'edubase.csv').freeze

  attr_accessor :email_override

  def initialize(email_override: nil)
    self.email_override = email_override
  end

  def sync
    import_all
    update_all
  ensure
    Rails.logger.debug("Deleting edubase data")
    File.delete(FILE_LOCATION)
  end

private

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
