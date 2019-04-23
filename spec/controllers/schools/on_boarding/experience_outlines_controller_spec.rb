require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::ExperienceOutlinesController, type: :request do
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
        :with_candidate_experience_detail,
        :with_availability_preference,
        :with_availability_description
    end

    before do
      get '/schools/on_boarding/experience_outline/new'
    end

    it 'assigns the model' do
      expect(assigns(:experience_outline)).to \
        eq Schools::OnBoarding::ExperienceOutline.new
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
        :with_candidate_experience_detail,
        :with_availability_preference,
        :with_availability_description
    end

    let :params do
      {
        schools_on_boarding_experience_outline: experience_outline.attributes
      }
    end

    before do
      post '/schools/on_boarding/experience_outline', params: params
    end

    context 'invalid' do
      let :experience_outline do
        Schools::OnBoarding::ExperienceOutline.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.experience_outline.attributes).to \
          eq experience_outline.attributes
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :experience_outline do
        FactoryBot.build :experience_outline
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.experience_outline).to \
          eq experience_outline
      end

      it 'redirects to the next_step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_admin_contact_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/experience_outline/edit'
    end

    it 'assigns the model' do
      expect(assigns(:experience_outline)).to eq school_profile.experience_outline
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
        schools_on_boarding_experience_outline: experience_outline.attributes
      }
    end

    before do
      patch '/schools/on_boarding/experience_outline', params: params
    end

    context 'invalid' do
      let :experience_outline do
        Schools::OnBoarding::ExperienceOutline.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.experience_outline).not_to eq experience_outline
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :experience_outline do
        FactoryBot.build :experience_outline, provides_teacher_training: false
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.experience_outline).to eq experience_outline
      end

      it 'redirects to the school_profile' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
