require 'rails_helper'
require_relative 'session_context'

describe Schools::DashboardsController, type: :request do
  context '#show' do
    include_context "logged in DfE user"

    let!(:school) do
      FactoryBot.create(:bookings_school, name: 'organisation one', urn: '356127')
    end

    before do
      get '/schools/dashboard'
    end

    it 'sets the correct school' do
      expect(assigns(:school)).to eq(school)
    end

    it 'renders the show template' do
      expect(response).to render_template :show
    end
  end
end
