require 'rails_helper'

describe Candidate::Registrations::PersonalDetailsController, type: :request do
  context '#new' do
    before do
      get '/candidate/registrations/personal_details/new'
    end

    it 'responds with 200' do
      expect(response.status).to eq 200
    end

    it 'renders the new form' do
      expect(response.body).to render_template :new
    end
  end

  context '#create' do
    before do
      post '/candidate/registrations/personal_details',
        params: personal_detail_params
    end

    context 'invalid' do
      let :personal_detail_params do
        {
          candidate_registrations_personal_detail: {
            building: 'Test house',
            street: 'Test street',
            town_or_city: 'Test Town',
            county: 'Testshire',
            postcode: 'TE57 1NG'
          }
        }
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :personal_detail_params do
        {
          candidate_registrations_personal_detail: {
            building: 'Test house',
            street: 'Test street',
            town_or_city: 'Test Town',
            county: 'Testshire',
            postcode: 'TE57 1NG',
            phone: '01234567890',
          }
        }
      end

      it 'stores the personal details in the session' do
        expect(session[:registration][:personal_details]).to eq(
          "building" => 'Test house',
          "street" => 'Test street',
          "town_or_city" => 'Test Town',
          "county" => 'Testshire',
          "postcode" => 'TE57 1NG',
          "phone" => '01234567890'
        )
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to '/candidate/registrations/account_info/new'
      end
    end
  end
end
