module Schools
  module PlacementRequests
    module Acceptance
      extend ActiveSupport::Concern

      included do
        before_action :set_placement_request
        before_action :fetch_gitis_contact_for_placement_request
      end

      def set_placement_request
        @placement_request = @current_school
          .bookings_placement_requests
          .find(params[:placement_request_id])
      end

      def fetch_gitis_contact_for_placement_request
        @placement_request.fetch_gitis_contact gitis_crm
      end
    end
  end
end
