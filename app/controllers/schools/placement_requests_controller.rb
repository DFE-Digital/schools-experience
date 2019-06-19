module Schools
  class PlacementRequestsController < Schools::BaseController
    def index
      @placement_requests = placement_requests
      assign_gitis_contacts(@placement_requests)
    end

    def show
      @placement_request = placement_request
      @gitis_contact = gitis_crm.find(placement_request.contact_uuid)
    end

  private

    def placement_requests
      current_school.placement_requests
        .eager_load(:candidate_cancellation, :school_cancellation, :placement_date)
    end

    def placement_request
      current_school.placement_requests.find params[:id]
    end

    def assign_gitis_contacts(reqs)
      return [] if reqs.empty?

      contacts = gitis_crm.find(reqs.map(&:contact_uuid)).index_by(&:id)

      reqs.each do |req|
        req.gitis_contact = contacts[req.contact_uuid]
      end

      reqs
    end
  end
end
