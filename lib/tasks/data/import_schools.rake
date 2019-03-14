require File.join(Rails.root, "lib", "data", "school_importer")

namespace :data do
  namespace :import do
    # The URNs should be provided in a CSV with the following two headings:
    # urn, contact_email
    #
    # The GiaS data is a dump taken from the Get Information About Schools
    # downloads page
    #
    # https://get-information-schools.service.gov.uk/Downloads
    desc "Import GiaS (EduBase) data based on a list of URNs"
    task :schools, %i{tpuk edubase} => :environment do |_t, args|
      tpuk_data = CSV.parse(
        File.read(args[:tpuk]).scrub,
        headers: true
      )

      edubase_data = CSV.parse(
        File.read(args[:edubase]).scrub,
        headers: true
      )

      SchoolImporter.new(tpuk_data, edubase_data).import
    end
  end
end
