class SchoolManager
  attr_accessor :urns

  def initialize(urns)
    self.urns = urns
  end

  def enable_urns
    set_enabled(true)
  end

  def disable_urns
    set_enabled(false)
  end

private

  def set_enabled(enabled)
    Bookings::School.transaction do
      urns.each do |row|
        Bookings::School.find_by(urn: row['urn']).tap do |bs|
          fail "no school found with urn #{row['urn']}" unless bs.present?

          puts "Updating #{bs.name}, enabled: #{enabled}"
          bs.update_attributes(enabled: enabled)
        end
      end
    end
  end
end
