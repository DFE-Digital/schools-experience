module Schools
  module PlacementRequests
    module Cancellations
      class NotificationDeliveriesController < Schools::BaseController
        before_action :set_placement_request
        before_action :fetch_gitis_contact_for_placement_request
        before_action :ensure_placement_request_is_open, except: :show

        def show
          @cancellation = @placement_request.school_cancellation
        end

        def create
          @cancellation = @placement_request.school_cancellation
          notify_candidate @cancellation
          @cancellation.sent!

          Bookings::Gitis::EventLogger.write_later \
            @cancellation.contact_uuid, :cancellation, @cancellation

          redirect_to \
            schools_placement_request_cancellation_notification_delivery_path @placement_request
        end

      private

        def set_placement_request
          @placement_request = \
            current_school.placement_requests.find params[:placement_request_id]
        end

        def fetch_gitis_contact_for_placement_request
          @placement_request.fetch_gitis_contact gitis_crm
        end

        def ensure_placement_request_is_open
          if @placement_request.closed?
            redirect_to schools_placement_requests_path @placement_request
          end
        end

        def notify_candidate(cancellation)
          NotifyEmail::CandidateRequestRejection.new(
            to: cancellation.candidate_email,
            school_name: cancellation.school_name,
            rejection_reasons: cancellation.reason,
            extra_details: cancellation.extra_details,
            dates_requested: cancellation.dates_requested,
            school_search_url: new_candidates_school_search_url
          ).despatch_later!
        end
      end
    end
  end
end
