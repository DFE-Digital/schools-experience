require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::AvailabilityPreferencesController, type: :request do
  include_context "logged in DfE user"
  include_context 'with phases'

  context '#new' do
    let! :school_profile do
      FactoryBot.create \
        :school_profile,
        :with_candidate_requirement,
        :with_fees,
        :with_administration_fee,
        :with_dbs_fee,
        :with_other_fee,
        :with_only_early_years_phase,
        :with_key_stage_list,
        :with_specialism,
        :with_candidate_experience_detail
    end

    before do
      get '/schools/on_boarding/availability_preference/new'
    end

    it 'assigns the model' do
      expect(assigns(:availability_preference)).to \
        eq Schools::OnBoarding::AvailabilityPreference.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let! :school_profile do
      FactoryBot.create \
        :school_profile,
        :with_candidate_requirement,
        :with_fees,
        :with_administration_fee,
        :with_dbs_fee,
        :with_other_fee,
        :with_only_early_years_phase,
        :with_key_stage_list,
        :with_specialism,
        :with_candidate_experience_detail
    end

    let :params do
      {
        schools_on_boarding_availability_preference: \
          availability_preference.attributes
      }
    end

    before do
      post '/schools/on_boarding/availability_preference', params: params
    end

    context 'valid' do
      let :availability_preference do
        FactoryBot.build :availability_preference, :fixed
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.availability_preference).to \
          eq availability_preference
      end

      it 'redirects to the next step' do
        expect(response).to \
          redirect_to new_schools_on_boarding_experience_outline_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/availability_preference/edit'
    end

    it 'assigns the model' do
      expect(assigns(:availability_preference)).to \
        eq school_profile.availability_preference
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
        schools_on_boarding_availability_preference: \
          availability_preference.attributes
      }
    end

    before do
      patch '/schools/on_boarding/availability_preference', params: params
    end

    context 'invalid' do
      let :availability_preference do
        Schools::OnBoarding::AvailabilityPreference.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.availability_preference).not_to \
          eq availability_preference
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :availability_preference do
        FactoryBot.build :availability_preference, :flexible
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.availability_preference).to \
          eq availability_preference
      end

      it 'redirects to the school_profile' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
