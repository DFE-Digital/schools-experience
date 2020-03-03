require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::ChangeSchoolsController, type: :request do
  include_context "logged in DfE user"
  let(:enable_signin_api) { true }
  let(:enable_school_change) { true }
  let(:old_school) { @current_user_school }
  let(:new_school) { create(:bookings_school) }

  before do
    allow(Schools::ChangeSchool).to \
      receive(:allow_school_change_in_app?) { enable_school_change }
  end

  describe '#show' do
    before do
      allow_any_instance_of(described_class).to \
        receive(:current_urn) { current_urn }
    end

    subject { get '/schools/change'; response }

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
    context 'when the user has access to the new school' do
      let(:urns) { [old_school, new_school].map(&:urn) }

      before do
        allow_any_instance_of(Schools::DFESignInAPI::Roles).to \
          receive(:has_school_experience_role?).and_return(true)

        allow_any_instance_of(Schools::DFESignInAPI::RoleCheckedOrganisations).to \
          receive(:organisation_uuid_pairs).and_return \
            SecureRandom.uuid => old_school.urn,
            SecureRandom.uuid => new_school.urn
      end

      let(:params) { { schools_change_school: { urn: new_school.urn } } }

      let(:change_school_page) { get '/schools/change' }
      subject { post('/schools/change', params: params) }

      it { is_expected.to redirect_to(schools_dashboard_path) }

      specify 'it should have updated the urn and name stored in the session' do
        change_school_page
        expect(request.session.fetch(:urn)).to eql(old_school.urn)

        subject
        expect(request.session.fetch(:urn)).to eql(new_school.urn)
        expect(request.session.fetch(:school_name)).to eql(new_school.name)
      end

      context 'role checking' do
        let(:roles_instance) { double Schools::DFESignInAPI::Roles, has_school_experience_role?: true }
        before do
          allow(Schools::DFESignInAPI::Roles).to receive(:new).and_return(roles_instance)
        end

        context 'when role checking is enabled' do
          before { subject }

          specify 'Schools::DFESignInAPI::Roles should be initialised' do
            expect(Schools::DFESignInAPI::Roles).to have_received(:new).exactly(1).times
          end
        end
      end
    end

    context 'when the user does not have access to the new school' do
      before do
        allow_any_instance_of(Schools::DFESignInAPI::RoleCheckedOrganisations).to \
          receive(:organisation_uuid_pairs).and_return \
            SecureRandom.uuid => new_school.urn

        allow_any_instance_of(Schools::DFESignInAPI::Roles).to \
          receive(:has_school_experience_role?).and_return(false)
      end
      let(:new_school) { create(:bookings_school) }
      let(:params) { { schools_change_school: { urn: new_school.urn } } }

      subject { post('/schools/change', params: params) }

      it 'should raise an invalid school error and redirect to an appropriate error page' do
        expect(subject).to redirect_to(schools_errors_inaccessible_school_path)
      end
    end

    context 'when internal changing is disabled' do
      let(:enable_signin_api) { false }
      let(:enable_school_change) { false }
      let(:params) { { schools_change_school: { urn: new_school.urn } } }
      let(:change_school_page) { get '/schools/change' }

      subject { post('/schools/change', params: params) }

      specify 'should fail with a 403: forbidden' do
        expect(subject).to eql(403)
      end
    end

    context 'when no existing urn set' do
      let(:urns) { [old_school, new_school].map(&:urn) }
      let(:params) { { schools_change_school: { urn: new_school.urn } } }
      let(:change_school_page) { get '/schools/change' }
      let(:new_school_uuid) { SecureRandom.uuid }

      before do
        allow_any_instance_of(described_class).to receive(:current_urn) { nil }

        allow_any_instance_of(Schools::DFESignInAPI::Organisations).to \
          receive(:uuids).and_return new_school_uuid => new_school.urn

        allow(Schools::DFESignInAPI::Roles).to receive(:new).and_call_original

        allow_any_instance_of(Schools::DFESignInAPI::Roles).to \
          receive(:has_school_experience_role?).and_return(true)
      end

      subject! { post('/schools/change', params: params) }

      it { is_expected.to redirect_to(schools_dashboard_path) }

      it 'calls roles API appropriately' do
        expect(Schools::DFESignInAPI::Roles).to \
          have_received(:new).with(user_guid, new_school_uuid).twice
      end
    end
  end
end
