require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::RejectedRequestsController, type: :request do
  include_context "logged in DfE user"
  include_context "fake gitis"

  let :school do
    Bookings::School.find_by!(urn: urn).tap do |school|
      school.subjects << FactoryBot.create_list(:bookings_subject, 2)
      create(:bookings_profile, school: school)
    end
  end

  describe '#index' do
    before do
      create_list(:placement_request, 2, :cancelled_by_school, school: school)
      get schools_rejected_requests_path
    end

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template('index') }
  end

  context "when the git_api feature is enabled" do
    include_context "enable git_api feature"

    describe "#index" do
      include_context "api sign ups for requests"

      let(:requests) { create_list(:placement_request, 2, :cancelled_by_school, school: school) }

      before do
        get schools_rejected_requests_path
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template('index') }
    end
  end

  describe '#show' do
    let(:rejected) { create :placement_request, :cancelled_by_school, school: school }
    before { get schools_rejected_request_path(rejected) }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template('show') }
    it { expect(rejected.school_cancellation.reload).not_to be_viewed }
  end
end
