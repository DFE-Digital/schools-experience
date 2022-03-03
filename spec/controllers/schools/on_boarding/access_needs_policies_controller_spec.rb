require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::AccessNeedsPoliciesController, type: :request do
  include_context "logged in DfE user"

  let! :school_profile do
    FactoryBot.create \
      :school_profile,
      :with_dbs_requirement,
      :with_candidate_requirements_selection,
      :with_fees,
      :with_administration_fee,
      :with_dbs_fee,
      :with_other_fee,
      :with_only_early_years_phase,
      :with_key_stage_list,
      :with_description,
      :with_candidate_dress_code,
      :with_candidate_experience_detail,
      :with_access_needs_support,
      :with_access_needs_detail,
      :with_disability_confident
  end

  context '#new' do
    before do
      get '/schools/on_boarding/access_needs_policy/new'
    end

    it 'assigns the model' do
      expect(assigns(:access_needs_policy)).to eq \
        Schools::OnBoarding::AccessNeedsPolicy.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :params do
      {
        schools_on_boarding_access_needs_policy: access_needs_policy.attributes
      }
    end

    before do
      post '/schools/on_boarding/access_needs_policy', params: params
    end

    context 'invalid' do
      let :access_needs_policy do
        Schools::OnBoarding::AccessNeedsPolicy.new
      end

      it 'doesnt update the school_profile' do
        expect(school_profile.reload.access_needs_policy).to eq \
          Schools::OnBoarding::AccessNeedsPolicy.new
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :access_needs_policy do
        FactoryBot.build :access_needs_policy
      end

      it 'updates the school profile' do
        expect(school_profile.reload.access_needs_policy).to eq \
          access_needs_policy
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_experience_outline_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/access_needs_policy/edit'
    end

    it 'assigns the form model' do
      expect(assigns(:access_needs_policy)).to \
        eq school_profile.access_needs_policy
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
        schools_on_boarding_access_needs_policy: \
          access_needs_policy.attributes
      }
    end

    before do
      patch '/schools/on_boarding/access_needs_policy', params: params
    end

    context 'invalid' do
      let :access_needs_policy do
        Schools::OnBoarding::AccessNeedsPolicy.new
      end

      it 'doesnt update the form model' do
        expect(school_profile.reload.access_needs_policy).not_to \
          eq access_needs_policy
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :access_needs_policy do
        FactoryBot.build :access_needs_policy,
          has_access_needs_policy: false,
          url: nil
      end

      it 'updates the form model' do
        expect(school_profile.reload.access_needs_policy).to \
          eq access_needs_policy
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
