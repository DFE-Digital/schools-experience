require 'rails_helper'

RSpec.describe Candidates::DashboardBaseController, type: :request do
  class StubController < Candidates::DashboardBaseController
    def index
      render plain: 'Authorized'
    end
  end

  describe "GET #index" do
    before do
      Rails.application.routes.send(:eval_block, -> {
        get 'restricted', to: 'stub#index'
      })
    end

    context 'when logged in' do
      include_context 'candidate signin'

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
