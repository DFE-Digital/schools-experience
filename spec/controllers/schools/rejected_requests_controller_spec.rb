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
    around do |example|
      Flipper.enable(:git_api)
      example.run
      Flipper.disable(:git_api)
    end

    describe "#index" do
      before do
        requests = create_list(:placement_request, 2, :cancelled_by_school, school: school)
        ids = requests.map(&:contact_uuid)
        sign_ups = ids.map { |id| build(:api_schools_experience_sign_up, candidate_id: id) }

        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:get_schools_experience_sign_ups)
            .with(a_collection_containing_exactly(*ids)) { sign_ups }

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
