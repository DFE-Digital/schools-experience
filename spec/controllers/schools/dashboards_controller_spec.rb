require 'rails_helper'
require_relative 'session_context'

describe Schools::DashboardsController, type: :request do
  context '#show' do
    include_context "logged in DfE user"

    before do
      get '/schools/dashboard'
    end

    it 'sets the correct school' do
      expect(assigns(:school)).to eq \
        Schools::School.new name: 'organisation one', urn: '356127'
    end

    it 'renders the show template' do
      expect(response).to render_template :show
    end
  end
end
