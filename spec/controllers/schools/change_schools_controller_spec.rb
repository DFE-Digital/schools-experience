require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::ChangeSchoolsController, type: :request do
  include_context "when a DfE user is logged in"
  include_context "when stubbing the role-check API"

  let(:enable_school_change) { true }
  let(:old_school) { current_user_school }
  let(:new_school) { create(:bookings_school) }

  before do
    allow(Schools::ChangeSchool).to \
      receive(:allow_school_change_in_app?) { enable_school_change }
  end

  describe '#show' do
    subject do
      get '/schools/change'
      response
    end

    before do
      session_hash[:urn] = current_urn
    end

    context 'with URN set' do
      let(:current_urn) { old_school.urn }

      it { is_expected.to have_http_status :success }
      it { is_expected.to have_rendered :show }
    end

    context 'with no URN set' do
      let(:current_urn) { nil }

      it { is_expected.to have_http_status :success }
      it { is_expected.to have_rendered :show }
    end
  end

  describe '#create' do
    let(:params) { { schools_change_school: { change_to_urn: new_school.urn } } }

    context 'when internal school chooser is enabled' do
      subject { post('/schools/change', params: params) }

      let(:urns) { [old_school, new_school].map(&:urn) }
      let(:change_school_page) { get '/schools/change' }

      before do
        organisations = instance_double(
          Schools::DFESignInAPI::RoleCheckedOrganisations,
          organisation_uuid_pairs: {
            SecureRandom.uuid => old_school.urn,
            SecureRandom.uuid => new_school.urn
          }
        )
        allow(Schools::DFESignInAPI::RoleCheckedOrganisations).to receive(:new).and_return(organisations)
      end

      context 'when the request access to another school option is chosen' do
        let(:params) { { schools_change_school: { change_to_urn: "request access" } } }

        it { is_expected.to redirect_to(schools_request_organisation_path) }
      end

      context 'when a school is chosen' do
        it { is_expected.to redirect_to(schools_dashboard_path) }

        specify 'it should have updated the urn and name stored in the session' do
          change_school_page
          expect(request.session.fetch(:urn)).to eql(old_school.urn)

          subject
          expect(request.session.fetch(:urn)).to eql(new_school.urn)
          expect(request.session.fetch(:school_name)).to eql(new_school.name)
        end
      end
    end

    context 'when internal changing is disabled' do
      subject { post('/schools/change', params: params) }

      let(:enable_school_change) { false }
      let(:change_school_page) { get '/schools/change' }

      specify 'should fail with a 403: forbidden' do
        expect(subject).to be(403)
      end
    end

    context 'when no existing urn set' do
      let(:urns) { [old_school, new_school].map(&:urn) }
      let(:change_school_page) { get '/schools/change' }
      let(:new_school_uuid) { SecureRandom.uuid }

      before do
        session_hash[:urn] = nil

        organisations = instance_double(
          Schools::DFESignInAPI::Organisations,
          uuids: { new_school_uuid => new_school.urn }
        )
        allow(Schools::DFESignInAPI::Organisations).to receive(:new).and_return(organisations)
      end

      subject! { post('/schools/change', params: params) } # rubocop:disable RSpec/LeadingSubject -- Request must run after role setup.

      it { is_expected.to redirect_to(schools_dashboard_path) }

      it 'calls roles API appropriately' do
        expect(Schools::DFESignInAPI::Roles).to \
          have_received(:new).with user_guid, new_school_uuid
      end
    end
  end
end
