module Candidates
  module Registrations
    class CreatePlacementRequestJob < GitisJob
      def perform(registration_uuid, contact_id, host, analytics_uuid)
        Candidates::Registrations::CreatePlacementRequest.
          new(gitis, registration_uuid, contact_id, host, analytics_uuid).
          create!
      end
    end
  end
end
