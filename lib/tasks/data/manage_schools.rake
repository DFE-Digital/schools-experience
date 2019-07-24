require File.join(Rails.root, "lib", "data", "school_importer")
require File.join(Rails.root, "lib", "data", "school_mass_importer")
require File.join(Rails.root, "lib", "data", "school_enhancer")
require File.join(Rails.root, "lib", "data", "school_manager")

namespace :data do
  namespace :schools do
    # The URNs should be provided in a CSV with the following two headings:
    # urn, contact_email
    #
    # The GiaS data is a dump taken from the Get Information About Schools
    # downloads page
    #
    # https://get-information-schools.service.gov.uk/Downloads
    #
    # If we don't want to run the risk of accidentally emailing anyone, provide
    # an email address in email_override and that will be set on all imported
    # records
    desc "Import GiaS (EduBase) data based on a list of URNs"
    task :import, %i{tpuk edubase email_override} => :environment do |_t, args|
      args.with_defaults(email_override: nil)

      tpuk_data = CSV.parse(
        File.read(args[:tpuk]).scrub,
        headers: true
      )

      edubase_data = CSV.parse(
        File.read(args[:edubase]).scrub,
        headers: true
      )

      SchoolImporter.new(tpuk_data, edubase_data, args[:email_override]).import
    end

    desc "Import all GiaS (EduBase) data"
    task :mass_import, %i{edubase email_override} => :environment do |_t, args|
      args.with_defaults(email_override: nil)

      edubase_data = CSV.parse(
        File.read(args[:edubase]).scrub,
        headers: true
      )

      SchoolMassImporter.new(edubase_data, args[:email_override]).import
    end

    desc "Enhance school data using information captured in the questionnaire"
    task :enhance, %i{questionnaire} => :environment do |_t, args|
      response_data = CSV.parse(
        File.read(args[:questionnaire]).scrub,
        headers: true
      )
      SchoolEnhancer.new(response_data).enhance
    end

    desc "Enable schools"
    task :enable, %i{urns} => :environment do |_t, args|
      response_data = CSV.parse(
        File.read(args[:urns]).scrub,
        headers: true
      )
      SchoolManager.new(response_data).enable_urns
    end

    desc "Disable schools"
    task :disable, %i{urns} => :environment do |_t, args|
      response_data = CSV.parse(
        File.read(args[:urns]).scrub,
        headers: true
      )
      SchoolManager.new(response_data).disable_urns
    end
  end
end
