require 'rails_helper'

describe Schools::OnBoarding::OtherFeesController, type: :request do
  let! :school_profile do
    FactoryBot.create \
      :school_profile,
      :with_candidate_requirement,
      :with_fees,
      :with_administration_fee,
      :with_dbs_fee
  end

  context '#new' do
    before do
      get '/schools/on_boarding/other_fee/new'
    end

    it 'assigns the model' do
      expect(assigns(:other_fee)).to eq Schools::OnBoarding::OtherFee.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :params do
      { schools_on_boarding_other_fee: other_fee.attributes }
    end

    before do
      post '/schools/on_boarding/other_fee', params: params
    end

    context 'invalid' do
      let :other_fee do
        Schools::OnBoarding::OtherFee.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.other_fee).to eq other_fee
      end

      it 'rerenders the new form' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :other_fee do
        FactoryBot.build :other_fee
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.other_fee).to eq other_fee
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to new_schools_on_boarding_phases_list_path
      end
    end
  end
end
