require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::PlacementRequests::Acceptance::ConfirmBookingController, type: :request do
  include_context "logged in DfE user"

  let!(:pr) { create(:bookings_placement_request, school: @current_user_school) }
  before { create(:bookings_profile, school: @current_user_school) }

  context '#new' do
    before do
      get new_schools_placement_request_acceptance_confirm_booking_path(pr.id)
    end

    specify 'renders the new template' do
      expect(response).to render_template(:new)
    end
  end
end
