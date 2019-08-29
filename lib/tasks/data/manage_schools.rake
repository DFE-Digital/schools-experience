require File.join(Rails.root, "lib", "data", "school_mass_importer")
require File.join(Rails.root, "lib", "data", "school_enhancer")
require File.join(Rails.root, "lib", "data", "school_manager")
require File.join(Rails.root, "lib", "data", "school_updater")

namespace :data do
  namespace :schools do
    desc "Import all GiaS (EduBase) data"
    task :mass_import, %i{edubase email_override} => :environment do |_t, args|
      args.with_defaults(email_override: nil)

      edubase_data = CSV.parse(
        File.read(args[:edubase]).scrub,
        headers: true
      )

      SchoolMassImporter.new(edubase_data, args[:email_override]).import
    end

    desc "Update schools"
    task :update, %i{edubase} => :environment do |_t, args|
      edubase_data = CSV.parse(
        File.read(args[:edubase]).scrub,
        headers: true
      )

      SchoolUpdater.new(edubase_data).update
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
