module Schools
  class RejectedRequestsController < Schools::BaseController
    def index
      @requests = scope
        .includes(:candidate, :school_cancellation, :subject, placement_date: :subjects)
        .page(params[:page])
        .per(50)

      assign_gitis_contacts @requests
    end

    def show
      @rejected_request = scope.find(params[:id])
      assign_gitis_contact @rejected_request

      @cancellation = @rejected_request.school_cancellation
    end

  private

    def scope
      current_school.placement_requests.rejected
    end

    def assign_gitis_contacts(requests)
      return requests if requests.empty?

      contact_ids = requests.map(&:contact_uuid)
      api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
      contacts = api.get_schools_experience_sign_ups(contact_ids).index_by(&:candidate_id)

      requests.each do |req|
        req.candidate.gitis_contact = contacts[req.contact_uuid]
      end
    end
  end
end
