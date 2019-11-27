require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::ChangeSchoolsController, type: :request do
  include_context "logged in DfE user"
  before { allow(Schools::DFESignInAPI::Client).to receive(:enabled?).and_return(true) }
  before { allow(Rails.application.config.x).to receive(:dfe_sign_in_api_enabled).and_return(true) }
  before { allow(Rails.application.config.x).to receive(:dfe_sign_in_api_school_change_enabled).and_return(true) }

  describe '#show' do
    subject { get '/schools/change' }
    let!(:profile) { create(:bookings_profile, school: @current_user_school) }
    before { subject }

    it { is_expected.to render_template(:show) }
  end

  describe '#create' do
    let(:old_school) { @current_user_school }
    let!(:profile) { create(:bookings_profile, school: @current_user_school) }

    context 'when the user has access to the new school' do
      let(:new_school) { create(:bookings_school) }
      let(:urns) { [old_school, new_school].map(&:urn) }

      before do
        allow_any_instance_of(Schools::DFESignInAPI::Organisations).to(
          receive(:urns).and_return(urns)
        )
      end

      let(:params) { { schools_change_school: { id: new_school.id } } }

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
    end

    context 'when the user does not have access to the new school' do
      before do
        allow_any_instance_of(Schools::DFESignInAPI::Organisations).to(
          receive(:urns).and_return([old_school.urn])
        )
      end
      let(:new_school) { create(:bookings_school) }
      let(:params) { { schools_change_school: { id: new_school.id } } }

      subject { post('/schools/change', params: params) }

      it 'should raise an invalid school error and redirect to an appropriate error page' do
        expect(subject).to redirect_to(schools_errors_inaccessible_school_path)
      end
    end
  end
end
