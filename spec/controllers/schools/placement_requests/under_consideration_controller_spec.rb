require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementRequests::UnderConsiderationController, type: :request do
  include_context "logged in DfE user"

  describe '#place_under_consideration' do
    include_context "logged in DfE user"

    let!(:pr) { create(:bookings_placement_request, school: @current_user_school) }
    before { create(:bookings_profile, school: @current_user_school) }

    subject do
      put schools_placement_request_schools_placement_requests_place_under_consideration_path(placement_request_id)
      response
    end

    context 'when there is a placement request' do
      let!(:pr) { create(:bookings_placement_request, school: @current_user_school) }
      let(:placement_request_id) { pr.id }
      before { create(:bookings_profile, school: @current_user_school) }

      it { is_expected.to have_http_status :redirect }
      it { is_expected.to redirect_to schools_placement_requests_path }
    end

    context 'when there is not a placement request' do
      let(:placement_request_id) { 1 }
      before { create(:bookings_profile, school: @current_user_school) }

      it { is_expected.to have_http_status :not_found }
    end
  end
end
