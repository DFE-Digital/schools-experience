class SchoolViewCountUpdater
  attr_accessor :seeds

  def initialize(seeds)
    self.seeds = CSV.read(seeds, headers: true)
  end

  def update
    Bookings::School.transaction do
      seeds.each do |row|
        urn        = row['urn']
        page_views = row['Pageviews'].to_i

        begin
          Bookings::School.find_by!(urn: urn).tap do |school|
            puts "Adding #{page_views} to #{school.name}'s count"

            school.update(views: (school.views + page_views))
          end
        rescue ActiveRecord::RecordNotFound
          puts "No school found with urn #{urn}"
        end
      end
    end
  end
end
