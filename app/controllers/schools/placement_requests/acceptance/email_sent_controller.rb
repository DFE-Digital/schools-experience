module Schools
  module PlacementRequests
    module Acceptance
      class EmailSentController < Schools::BaseController
        include Acceptance

        def show
          set_placement_request_and_fetch_gitis_contact

          unless @placement_request.booking.accepted?
            redirect_to new_schools_placement_request_acceptance_make_changes_path(@placement_request.id)
          end
        end
      end
    end
  end
end
