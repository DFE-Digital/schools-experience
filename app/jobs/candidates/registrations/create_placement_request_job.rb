module Candidates
  module Registrations
    class CreatePlacementRequestJob < ApplicationJob
      def perform(placement_id, registration_uuid, contact_id, host)
        Candidates::Registrations::CreatePlacementRequest.
          new(placement_id, registration_uuid, contact_id, host).
          create!
      end
    end
  end
end
