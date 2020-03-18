module Schools
  class WrongSchoolError < StandardError
    attr_reader :urn

    def initialize(urn:)
      @urn = urn
      super
    end
  end

  class PlacementRequestsController < Schools::BaseController
    rescue_from WrongSchoolError, with: :switch_school

    def index
      @placement_requests = placement_requests
      assign_gitis_contacts(@placement_requests)
    end

    def show
      @placement_request = placement_request

      @gitis_contact = assign_gitis_contact(placement_request).gitis_contact

      @placement_request.viewed!

      if @placement_request.candidate_cancellation
        @placement_request.candidate_cancellation.viewed!
      end

      @attendance = Schools::AttendanceRecords.new \
        @placement_request.candidate_id, school_urns
    end

  private

    def placement_requests
      current_school
        .placement_requests
        .unbooked
        .eager_load(:candidate, :candidate_cancellation, :school_cancellation, :placement_date, :booking, :subject)
        .order(created_at: 'desc')
        .page(params[:page])
    end

    def placement_request
      current_school.placement_requests.find params[:id]
    rescue ActiveRecord::RecordNotFound => e
      if (other_school_urn = user_has_access_via_another_school)
        return raise WrongSchoolError.new(urn: other_school_urn)
      end

      raise e
    end

    def switch_school(exception)
      redirect_to schools_switch_path(urn: exception.urn)
    end

    def user_has_access_via_another_school
      return false unless DFESignInAPI::Client.enabled?

      placement_request_urn = Bookings::PlacementRequest
        .eager_load(:school)
        .find(params[:id])
        .school
        .urn

      placement_request_urn if other_school_urns.include? placement_request_urn
    end
  end
end
