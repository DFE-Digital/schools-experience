require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::FeesController, type: :request do
  include_context "logged in DfE user"
  include_context 'with phases'

  context '#new' do
    let! :school_profile do
      FactoryBot.create :school_profile, :with_candidate_requirement
    end

    before do
      get '/schools/on_boarding/fees/new'
    end

    it 'assigns the model' do
      expect(assigns(:fees)).to eq Schools::OnBoarding::Fees.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let! :school_profile do
      FactoryBot.create :school_profile, :with_candidate_requirement
    end

    let :params do
      { schools_on_boarding_fees: fees.attributes }
    end

    before do
      post '/schools/on_boarding/fees', params: params
    end

    context 'invalid' do
      let :fees do
        Schools::OnBoarding::Fees.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.fees).to eq fees
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :fees do
        FactoryBot.build :fees
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.fees.attributes).to eq fees.attributes
      end

      it 'redirects to the correct_step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_administration_fee_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/fees/edit'
    end

    it 'assigns the model' do
      expect(assigns(:fees)).to eq school_profile.fees
    end

    it 'renders the edit template' do
      expect(response).to render_template :edit
    end
  end

  context '#update' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    let :params do
      {
        schools_on_boarding_fees: fees.attributes
      }
    end

    before do
      patch '/schools/on_boarding/fees', params: params
    end

    context 'invalid' do
      let :fees do
        Schools::OnBoarding::Fees.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.fees).not_to eq fees
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :fees do
        FactoryBot.build :fees, dbs_fees: !school_profile.dbs_fee
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.fees).to eq fees
      end

      it 'redirects to the school_profile' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
