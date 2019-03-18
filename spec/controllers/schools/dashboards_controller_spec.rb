require 'rails_helper'

describe Schools::DashboardsController, type: :request do
  context '#show' do
    before do
      get '/schools/dashboard'
    end

    it 'sets the correct school' do
      expect(assigns(:school)).to eq \
        Schools::School.new name: 'organisation one', urn: 1234567890
    end

    it 'renders the show template' do
      expect(response).to render_template :show
    end
  end
end
