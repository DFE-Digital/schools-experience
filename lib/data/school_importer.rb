class SchoolImporter
  attr_accessor :urns, :edubase_data
  def initialize(urns, edubase_data)
    self.urns         = urns
    self.edubase_data = edubase_data
  end

  def import
    total = @urns.length
    Bookings::School.transaction do
      @urns.each.with_index(1) do |urn, i|
        unless (school = @edubase_data[urn])
          raise "URN #{urn} cannot be found in dataset"
        end

        #Bookings::School.new(
          # blah
        #)

        puts "%<count>s of %<total>d | %<urn>s | %<name>s" % {
          count: i.to_s.rjust(3),
          total: total,
          urn: urn.to_s.rjust(8),
          name: school['EstablishmentName']
        }
      end
    end
  end
end
