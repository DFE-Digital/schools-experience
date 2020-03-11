require 'rails_helper'
require_relative 'session_context'

describe Schools::DashboardsController, type: :request do
  let(:service_update) { build :service_update }

  context '#show' do
    before { allow(ServiceUpdate).to receive(:latest) { service_update } }

    context 'when a school exists' do
      let!(:school) do
        FactoryBot.create(:bookings_school, name: 'organisation one', urn: '123456')
      end

      context 'when logged in' do
        include_context "logged in DfE user"

        subject! { get '/schools/dashboard' }

        it 'sets the correct school' do
          expect(assigns(:school)).to eq(school)
        end

        it 'renders the show template' do
          expect(response).to render_template :show
        end

        it 'sets the latest_service_update' do
          expect(assigns[:latest_service_update]).to eq ServiceUpdate.latest
        end

        it 'sets view_latest_service_update' do
          expect(assigns[:viewed_latest_service_update]).to be false
        end
      end

      context 'when viewed latest update' do
        before do
          cookies[ServiceUpdate.cookie_key] = ServiceUpdate.latest.to_param
        end
        include_context "logged in DfE user"

        subject! { get '/schools/dashboard' }

        it 'sets view_latest_service_update' do
          expect(assigns[:viewed_latest_service_update]).to be true
        end
      end

      context 'when not logged in' do
        subject { get '/schools/dashboard' }
        it_behaves_like "a protected page"
      end
    end

    context "when the school doesn't exist" do
      include_context "logged in DfE user"
      subject { get '/schools/dashboard' }

      before do
        @current_user_school.destroy!
      end

      specify 'should redirect to school not registered error page' do
        expect(subject).to redirect_to(schools_errors_not_registered_path)
      end
    end

    context "when the urn isn't present in the session" do
      include_context "logged in DfE user"

      before do
        allow(Schools::ChangeSchool).to \
          receive(:allow_school_change_in_app?) { allow_school_change }

        allow_any_instance_of(described_class).to receive(:current_urn) { nil }
        get '/schools/dashboard'
      end

      context 'and in app school change is deactivated' do
        let(:allow_school_change) { false }

        specify 'should redirect to school not registered error page' do
          expect(subject).to \
            redirect_to(schools_errors_insufficient_privileges_path)
        end
      end

      context 'and DfE Sign-in api integration is activated' do
        let(:allow_school_change) { true }

        specify 'should redirect to change school page' do
          expect(subject).to redirect_to(schools_change_path)
        end
      end
    end
  end
end
