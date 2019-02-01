require File.join(Rails.root, "lib", "data", "school_importer")

namespace :data do
  namespace :import do
    # The URNs should be provided in a file with one URN per line, the GiaS
    # data is a dump taken from the Get Information About Schools downloads
    # page
    # https://get-information-schools.service.gov.uk/Downloads
    desc "Import GiaS (EduBase) data based on a list of URNs"
    task :schools, %i{urnlist edubasedump} => :environment do |_t, args|
      urns = File.readlines(args[:urnlist])
      edubase_data = CSV.parse(
        File.read(args[:edubasedump]).scrub, headers: true
      )

      SchoolImporter.new(urns, edubase_data).import
    end
  end
end
