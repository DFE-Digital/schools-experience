require 'rails_helper'

RSpec.describe Candidates::DashboardBaseController, type: :request do
  class StubController < Candidates::DashboardBaseController
    def index
      render plain: 'Authorized'
    end
  end

  Rails.application.routes.send(:eval_block, -> {
    get 'restricted', to: 'stub#index'
  })

  describe "GET #show" do
    let(:contact_attrs) { attributes_for(:gitis_contact, :persisted) }

    context 'when logged in' do
      before do
        allow_any_instance_of(ActionDispatch::Request).to \
          receive(:session).and_return(gitis_contact: contact_attrs)
      end

      before { get '/restricted' }

      it "returns http success" do
        expect(response).to have_http_status(:success)
        expect(response.body).to match('Authorized')
      end
    end

    context 'when not logged in' do
      before { get '/restricted' }

      it "returns http success" do
        expect(response).to redirect_to(candidates_signin_path)
      end
    end
  end
end
