module Schools
  module PlacementRequests
    class PastAttendanceController < BaseController
      def index
        @placement_request = load_placement_request

        @candidate = @placement_request.candidate
        @candidate.fetch_gitis_contact gitis_crm

        @attendance = load_attendance_records(@candidate.id, school_urns).to_a
      end

    private

      def load_placement_request
        current_school.placement_requests.find params[:placement_request_id]
      end

      def load_attendance_records(candidate_id, urns)
        AttendanceRecords.new(candidate_id, urns) \
          .records
          .order(date: :desc)
          .limit(50)
          .includes(:bookings_school, :bookings_subject)
      end
    end
  end
end
