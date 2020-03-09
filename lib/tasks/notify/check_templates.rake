require Rails.root.join("lib", "notify", "notify_sync")

namespace :notify do
  desc "See if local copies of email templates are up to date"
  task compare_local_and_remote_templates: :environment do
    NotifySync.new.compare
  end

  desc "Pull remote templates"
  task pull_remote_templates: :environment do
    NotifySync.new.pull
  end
end
