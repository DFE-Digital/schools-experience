require 'rails_helper'

require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::KeyStageListsController, type: :request do
  include_context "logged in DfE user"
  include_context 'with phases'

  let! :school_profile do
    FactoryBot.create \
      :school_profile,
      :with_candidate_requirement,
      :with_fees,
      :with_administration_fee,
      :with_dbs_fee,
      :with_other_fee,
      :with_phases
  end

  context '#new' do
    before do
      get '/schools/on_boarding/key_stage_list/new'
    end

    it 'assings the model' do
      expect(assigns(:key_stage_list)).to \
        eq Schools::OnBoarding::KeyStageList.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :params do
      { schools_on_boarding_key_stage_list: key_stage_list.attributes }
    end

    before do
      post '/schools/on_boarding/key_stage_list/', params: params
    end

    context 'invalid' do
      let :key_stage_list do
        Schools::OnBoarding::KeyStageList.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.key_stage_list).to eq key_stage_list
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :key_stage_list do
        FactoryBot.build :key_stage_list
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.key_stage_list).to eq key_stage_list
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_secondary_subjects_path
      end
    end
  end
end
