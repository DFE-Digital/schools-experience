require File.join(Rails.root, "lib", "data", "school_view_count_updater")

namespace :data do
  namespace :schools do
    # Note that seeds should be downloaded from the 'School Page View'
    # report in Google Data Manager
    desc "Update school counters with stats from Google Analytics"
    task :update_counters, %i{seeds} => :environment do |_t, args|
      seeds = args[:seeds]

      fail 'no seed data provided' unless seeds.present?

      SchoolViewCountUpdater.new(seeds).update
    end
  end
end
