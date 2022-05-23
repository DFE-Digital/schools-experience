require "placement_request_transfer"

namespace :data do
  namespace :placement_requests do
    # Important: see notes in PlacementRequestTransfer class!
    desc "Transfer a placement request from one school to another"
    task :transfer, %i[placement_request_id school_id] => :environment do |_t, args|
      placement_request_id, school_id = args.values_at(:placement_request_id, :school_id)

      PlacementRequestTransfer.new(placement_request_id, school_id).transfer!
    end
  end
end
