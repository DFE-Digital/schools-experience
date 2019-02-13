require File.join(Rails.root, "lib", "notify", "check_local_copies")

namespace :notify do
  desc "See if local copies of email templates are up to date"
  task :check_local_copies, %i{diff} => :environment do |_t, args|
    args.with_defaults(diff: false)
    NotifySync.new.compare(args[:diff])
  end
end
