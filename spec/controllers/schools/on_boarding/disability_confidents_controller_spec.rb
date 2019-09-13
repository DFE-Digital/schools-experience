require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::DisabilityConfidentsController, type: :request do
  include_context "logged in DfE user"

  let! :school_profile do
    FactoryBot.create \
      :school_profile,
      :with_dbs_requirement,
      :with_candidate_requirement,
      :with_fees,
      :with_administration_fee,
      :with_dbs_fee,
      :with_other_fee,
      :with_only_early_years_phase,
      :with_key_stage_list,
      :with_description,
      :with_candidate_experience_detail,
      :with_access_needs_support,
      :with_access_needs_detail
  end

  context '#new' do
    before do
      get '/schools/on_boarding/disability_confident/new'
    end

    it 'assigns the model' do
      expect(assigns(:disability_confident)).to eq \
        Schools::OnBoarding::DisabilityConfident.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :params do
      {
        schools_on_boarding_disability_confident: \
          disability_confident.attributes
      }
    end

    before do
      post '/schools/on_boarding/disability_confident', params: params
    end

    context 'invalid' do
      let :disability_confident do
        Schools::OnBoarding::DisabilityConfident.new
      end

      it 'doesnt update the school profile' do
        expect(school_profile.reload.disability_confident).to eq \
          Schools::OnBoarding::DisabilityConfident.new
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :disability_confident do
        FactoryBot.build :disability_confident
      end

      it 'updates the school profile' do
        expect(school_profile.reload.disability_confident).to eq \
          disability_confident
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_access_needs_policy_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/disability_confident/edit'
    end

    it 'assigns the form model' do
      expect(assigns(:disability_confident)).to \
        eq school_profile.disability_confident
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
        schools_on_boarding_disability_confident: \
          disability_confident.attributes
      }
    end

    before do
      patch '/schools/on_boarding/disability_confident', params: params
    end

    context 'invalid' do
      let :disability_confident do
        Schools::OnBoarding::AccessNeedsSupport.new
      end

      it 'doesnt update the form model' do
        expect(school_profile.reload.disability_confident).not_to \
          eq disability_confident
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :disability_confident do
        FactoryBot.build :disability_confident, is_disability_confident: false
      end

      it 'updates the form model' do
        expect(school_profile.reload.disability_confident).to \
          eq disability_confident
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
