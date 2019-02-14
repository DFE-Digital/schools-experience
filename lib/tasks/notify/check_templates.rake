require File.join(Rails.root, "lib", "notify", "notify_sync")

namespace :notify do
  desc "See if local copies of email templates are up to date"
  task :compare_local_and_remote_templates, %i{diff} => :environment do |_t, args|
    args.with_defaults(diff: false)
    NotifySync.new.compare(args[:diff])
  end

  desc "Pull remote templates"
  task pull_remote_templates: :environment do |_t|
    NotifySync.new.pull
  end
end
