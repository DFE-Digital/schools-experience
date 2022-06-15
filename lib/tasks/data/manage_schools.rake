namespace :data do
  namespace :schools do
    desc "Import all GiaS (EduBase) data from local file"
    task :mass_import, %i[email_override] => :environment do |_t, args|
      args.with_defaults(email_override: nil)

      Bookings::SchoolSync.new(email_override: args[:email_override]).import_all
    end

    desc "Update schools"
    task update: :environment do |_t, _args|
      Bookings::SchoolSync.new.update_all
    end

    desc "Enable schools"
    task :enable, %i[urns] => :environment do |_t, args|
      response_data = CSV.parse(
        File.read(args[:urns]).scrub,
        headers: true
      )
      Bookings::Data::SchoolManager.new(response_data).enable_urns
    end

    desc "Disable schools"
    task :disable, %i[urns] => :environment do |_t, args|
      response_data = CSV.parse(
        File.read(args[:urns]).scrub,
        headers: true
      )
      Bookings::Data::SchoolManager.new(response_data).disable_urns
    end

    desc "Find on-boarded schools that have subsequently closed (and the urn of matching/replacement schools now open)"
    task identify_onboarded_closed: :environment do |_t, _args|
      reconciler = Bookings::Data::GiasReconciler.new
      schools = reconciler.identify_onboarded_closed
      reopened_urns = reconciler.find_reopened_urns(schools.pluck(:urn))

      results = schools.map do |s|
        [s.urn, s.name, s.enabled, reopened_urns[s.urn].join("|")]
      end

      puts(results.map { |row| row.join(", ") })
    end
  end
end
