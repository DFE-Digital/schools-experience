module Schools
  class WithdrawnRequestsController < Schools::BaseController
    def index
      @requests = scope
        .includes(:candidate, :candidate_cancellation, placement_date: :subjects)
        .order(created_at: :desc)
        .page(params[:page])
        .per(50)

      assign_gitis_contacts @requests
    end

  private

    def scope
      current_school.placement_requests.withdrawn
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
