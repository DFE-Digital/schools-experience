module Schools
  class PlacementRequestsController < Schools::BaseController
    def index
      @placement_requests = placement_requests
      assign_gitis_contacts(@placement_requests)
    end

    def show
      @placement_request = placement_request
      @gitis_contact = placement_request.fetch_gitis_contact(gitis_crm)

      @placement_request.viewed!

      if @placement_request.candidate_cancellation
        @placement_request.candidate_cancellation.viewed!
      end
    end

  private

    def placement_requests
      current_school
        .placement_requests
        .unbooked
        .eager_load(:candidate, :candidate_cancellation, :school_cancellation, :placement_date, :booking)
        .order(created_at: 'desc')
    end

    def placement_request
      current_school.placement_requests.find params[:id]
    end

    def assign_gitis_contacts(reqs)
      return reqs if reqs.empty?

      contacts = gitis_crm.find(reqs.map(&:contact_uuid)).index_by(&:id)

      reqs.each do |req|
        req.candidate.gitis_contact = contacts[req.contact_uuid]
      end
    end
  end
end
