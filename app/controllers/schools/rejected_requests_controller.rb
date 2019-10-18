module Schools
  class RejectedRequestsController < Schools::BaseController
    def index
      @requests = scope
        .includes(:candidate, :school_cancellation, placement_date: :subjects)
        .page(params[:page])
        .per(50)

      assign_gitis_contacts @requests
    end

    def show
      @rejected_request = scope.find(params[:id])
      @rejected_request.fetch_gitis_contact gitis_crm

      @cancellation = @rejected_request.school_cancellation
    end

  private

    def scope
      current_school.placement_requests.rejected
    end

    def assign_gitis_contacts(requests)
      return requests if requests.empty?

      contacts = gitis_crm.find(requests.map(&:contact_uuid)).index_by(&:id)

      requests.each do |req|
        req.candidate.gitis_contact = contacts[req.contact_uuid]
      end
    end
  end
end
