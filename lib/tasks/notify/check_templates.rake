require File.join(Rails.root, "lib", "notify", "check_local_copies")

namespace :notify do
  desc "See if local copies of email templates are up to date"
  task :check_local_copies, %i{} => :environment do |_t|
    CheckLocalCopies.new.compare
  end
end
