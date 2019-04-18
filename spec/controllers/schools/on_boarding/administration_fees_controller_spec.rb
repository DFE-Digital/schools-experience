require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::AdministrationFeesController, type: :request do
  include_context "logged in DfE user"
  include_context 'with phases'

  let! :school_profile do
    FactoryBot.create :school_profile, :with_candidate_requirement, :with_fees
  end

  context '#new' do
    before do
      get '/schools/on_boarding/administration_fee/new'
    end

    it 'assigns the model' do
      expect(assigns(:administration_fee)).to eq \
        Schools::OnBoarding::AdministrationFee.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :params do
      { schools_on_boarding_administration_fee: administration_fee.attributes }
    end

    before do
      post '/schools/on_boarding/administration_fee', params: params
    end

    context 'invalid' do
      let :administration_fee do
        Schools::OnBoarding::AdministrationFee.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.administration_fee).to eq \
          administration_fee
      end

      it 'rerenders the new form' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :administration_fee do
        FactoryBot.build :administration_fee
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.administration_fee).to eq \
          administration_fee
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to new_schools_on_boarding_dbs_fee_path
      end
    end
  end
end
