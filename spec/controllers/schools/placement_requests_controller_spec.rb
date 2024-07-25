require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementRequestsController, type: :request do
  include ActiveSupport::Testing::TimeHelpers
  include_context "logged in DfE user"
  include_context "Degree subject autocomplete enabled"

  let :school do
    Bookings::School.find_by! urn: urn
  end

  let! :profile do
    create(:bookings_profile, school: school)
  end

  before do
    school.subjects << FactoryBot.create_list(:bookings_subject, 1)
  end

  context '#index' do
    let!(:placement_requests) do
      FactoryBot.create_list :placement_request, 2, school: school
    end

    context 'with expired placement requests' do
      before do
        @flex_recent_expired = create :placement_request, created_at: 2.days.ago, school: school
        @flex_old_expired = create :placement_request, created_at: 2.months.ago, school: school
        school.update(availability_preference_fixed: true)
        @fixed_recent_expired = create(:placement_request, :with_a_fixed_date_in_the_recent_past, school: school)
        @fixed_old_expired = create(:placement_request, :with_a_fixed_date_in_the_past, school: school)

        get '/schools/placement_requests'
      end

      it 'displays fixed placement requests that expired within a month' do
        expect(assigns(:placement_requests)).to include @fixed_recent_expired
      end

      it 'displays flex placement requests that expired within two months' do
        expect(assigns(:placement_requests)).to include @flex_recent_expired
      end

      it 'does not display expired request that are older than a month' do
        expect(assigns(:placement_requests)).not_to include @fixed_old_expired
      end

      it 'does not display expired request that are older than a month' do
        expect(assigns(:placement_requests)).not_to include @flex_old_expired
      end

      it 'displays both recently expired fixed and flex placement requests' do
        expect(assigns(:placement_requests).count).to eq(4)
      end
    end

    context 'for unaccepted placement requests' do
      before { get '/schools/placement_requests' }

      it 'assigns the placement_requests belonging to the school' do
        expect(assigns(:placement_requests)).to match_array school.placement_requests
        expect(assigns(:placement_requests).map(&:gitis_contact)).to all \
          be_kind_of GetIntoTeachingApiClient::SchoolsExperienceSignUp
      end

      it 'renders the index template' do
        expect(response).to render_template :index
      end
    end

    context 'after placement requests have been accepted' do
      let(:booked) { placement_requests.last }
      before do
        create :bookings_booking, :accepted,
          bookings_placement_request: booked,
          bookings_school: school

        get '/schools/placement_requests'
      end

      specify 'they should be omitted' do
        expect(assigns(:placement_requests)).to \
          match_array(school.placement_requests - [booked])
      end
    end

    context 'after placement requests have been rejected' do
      let(:rejected) { placement_requests.last }
      before do
        create :cancellation, :cancelled_by_school,
          placement_request: rejected

        get '/schools/placement_requests'
      end

      specify 'they should be omitted' do
        expect(assigns(:placement_requests)).not_to include(rejected)
      end
    end

    context "with a timeout response from the API" do
      before do
        ids = placement_requests.map(&:contact_uuid)
        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:get_schools_experience_sign_ups)
            .with(a_collection_containing_exactly(*ids))
            .and_raise(Faraday::ConnectionFailed.new("failed"))
        get "/schools/placement_requests"
      end

      it "renders the Gitis connection error page" do
        expect(response).to have_http_status(:service_unavailable)
        expect(response).to render_template('shared/failed_gitis_connection')
      end
    end

    context "with a missing contact from API" do
      before do
        ids = placement_requests.map(&:contact_uuid)
        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:get_schools_experience_sign_ups)
            .with(a_collection_containing_exactly(*ids)) { [] }
        get "/schools/placement_requests"
      end

      it "renders the Gitis connection error page" do
        expect(response).to have_http_status(:success)
        expect(response).to render_template('index')
        expect(response.body).to match(/Unavailable/)
      end
    end
  end

  context '#show' do
    context 'with a new placement request' do
      before do
        get "/schools/placement_requests/#{placement_request.id}"
      end

      let :placement_request do
        FactoryBot.create :placement_request, school: school
      end

      before { get "/schools/placement_requests/#{placement_request.id}" }

      it 'assigns the correct placement_request' do
        expect(assigns(:placement_request)).to eq placement_request
      end

      it 'renders the show template' do
        expect(response).to render_template :show
      end
    end

    context 'with a placement request cancelled by candidate' do
      before do
        get "/schools/placement_requests/#{placement_request.id}"
      end

      let :placement_request do
        create :placement_request, :cancelled, school: school
      end

      before { get "/schools/placement_requests/#{placement_request.id}" }

      it 'marks the cancellation as viewed' do
        expect(placement_request.reload.candidate_cancellation).to be_viewed
      end
    end

    context 'cannot find the placement request' do
      subject { get(schools_placement_request_path(placement_request.id)) }
      let(:another_school) { create(:bookings_school) }
      let(:placement_request) { create(:bookings_placement_request, school: another_school) }

      context 'when the user has access via another school' do
        before do
          allow(Schools::DFESignInAPI::Client).to receive(:enabled?).and_return(true)

          allow_any_instance_of(Schools::DFESignInAPI::RoleCheckedOrganisations).to \
            receive(:organisation_uuid_pairs).and_return \
              SecureRandom.uuid => another_school.urn
        end

        specify 'redirects to the switch school page with urn param present' do
          expect(subject).to redirect_to(schools_switch_path(urn: another_school.urn))
        end
      end

      context 'when the DfE Sign-in API is disabled' do
        before do
          allow(Schools::DFESignInAPI::Client).to receive(:enabled?).and_return(false)
        end

        specify 'should raise a record not found error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when the user has no access via any school' do
        before do
          allow(Schools::DFESignInAPI::Client).to receive(:enabled?).and_return(true)

          allow_any_instance_of(Schools::DFESignInAPI::RoleCheckedOrganisations).to \
            receive(:organisation_uuid_pairs).and_return({})
        end

        specify 'should raise a record not found error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'with a timeout response from Gitis' do
      let :placement_request do
        FactoryBot.create :placement_request, school: school
      end

      before do
        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:get_schools_experience_sign_up)
            .with(placement_request.candidate.gitis_uuid)
            .and_raise(Faraday::ConnectionFailed.new("timeout"))

        get "/schools/placement_requests/#{placement_request.id}"
      end

      it "renders the Gitis connection error page" do
        expect(response).to have_http_status(:service_unavailable)
        expect(response).to render_template('shared/failed_gitis_connection')
      end
    end

    context 'with a 404 response from Gitis' do
      let :placement_request do
        FactoryBot.create :placement_request, school: school
      end

      before do
        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:get_schools_experience_sign_up)
            .with(placement_request.candidate.gitis_uuid)
            .and_raise(GetIntoTeachingApiClient::ApiError.new(code: 404))

        get "/schools/placement_requests/#{placement_request.id}"
      end

      it "renders the Gitis connection error page" do
        expect(response).to have_http_status(:service_unavailable)
        expect(response).to render_template('shared/failed_gitis_connection')
      end
    end
  end
end
