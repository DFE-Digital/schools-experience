require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::AccessNeedsSupportsController, type: :request do
  include_context "logged in DfE user"

  context '#new' do
    let! :school_profile do
      FactoryBot.create \
        :school_profile,
        :with_dbs_requirement,
        :with_candidate_requirements_choice,
        :with_candidate_requirements_selection,
        :with_fees,
        :with_administration_fee,
        :with_dbs_fee,
        :with_other_fee,
        :with_only_early_years_phase,
        :with_key_stage_list,
        :with_description,
        :with_candidate_experience_detail
    end

    before do
      get '/schools/on_boarding/access_needs_support/new'
    end

    it 'assigns the model' do
      expect(assigns(:access_needs_support)).to \
        eq Schools::OnBoarding::AccessNeedsSupport.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let! :school_profile do
      FactoryBot.create \
        :school_profile,
        :with_dbs_requirement,
        :with_candidate_requirements_choice,
        :with_candidate_requirements_selection,
        :with_fees,
        :with_administration_fee,
        :with_dbs_fee,
        :with_other_fee,
        :with_only_early_years_phase,
        :with_key_stage_list,
        :with_description,
        :with_candidate_experience_detail
    end

    let :params do
      {
        schools_on_boarding_access_needs_support: \
          access_needs_support.attributes
      }
    end

    before do
      post '/schools/on_boarding/access_needs_support', params: params
    end

    context 'invalid' do
      let :access_needs_support do
        Schools::OnBoarding::AccessNeedsSupport.new
      end

      it 'doesnt update the school_profile' do
        expect(school_profile.reload.access_needs_support).to eq \
          Schools::OnBoarding::AccessNeedsSupport.new
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :access_needs_support do
        build :access_needs_support
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.access_needs_support).to \
          eq access_needs_support
      end

      it 'redirects to the next_step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_access_needs_detail_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/access_needs_support/edit'
    end

    it 'assigns the form model' do
      expect(assigns(:access_needs_support)).to \
        eq school_profile.access_needs_support
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
        schools_on_boarding_access_needs_support: \
          access_needs_support.attributes
      }
    end

    before do
      patch '/schools/on_boarding/access_needs_support', params: params
    end

    context 'invalid' do
      let :access_needs_support do
        Schools::OnBoarding::AccessNeedsSupport.new
      end

      it 'doesnt update the form model' do
        expect(school_profile.reload.access_needs_support).not_to \
          eq access_needs_support
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :access_needs_support do
        FactoryBot.build :access_needs_support, supports_access_needs: false
      end

      it 'updates the form model' do
        expect(school_profile.reload.access_needs_support).to \
          eq access_needs_support
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
