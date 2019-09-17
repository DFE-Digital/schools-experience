module Candidates
  module Registrations
    class CreatePlacementRequestJob < ApplicationJob
      def perform(registration_uuid, contact_id, host, analytics_uuid)
        Candidates::Registrations::CreatePlacementRequest.
          new(registration_uuid, contact_id, host, analytics_uuid).
          create!
      end
    end
  end
end
