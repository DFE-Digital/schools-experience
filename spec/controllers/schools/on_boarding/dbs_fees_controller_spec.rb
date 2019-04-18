require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::DbsFeesController, type: :request do
  include_context "logged in DfE user"
  include_context 'with phases'

  let! :school_profile do
    FactoryBot.create \
      :school_profile,
      :with_candidate_requirement,
      :with_fees,
      :with_administration_fee
  end

  context '#new' do
    before do
      get '/schools/on_boarding/dbs_fee/new'
    end

    it 'assigns the model' do
      expect(assigns(:dbs_fee)).to eq Schools::OnBoarding::DBSFee.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :params do
      { schools_on_boarding_dbs_fee: dbs_fee.attributes }
    end

    before do
      post '/schools/on_boarding/dbs_fee', params: params
    end

    context 'invalid' do
      let :dbs_fee do
        Schools::OnBoarding::DBSFee.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.dbs_fee).to eq dbs_fee
      end

      it 'rerenders the new form' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :dbs_fee do
        FactoryBot.build :dbs_fee
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.dbs_fee).to eq dbs_fee
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to new_schools_on_boarding_other_fee_path
      end
    end
  end
end
