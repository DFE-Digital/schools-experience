require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::TeacherTrainingsController, type: :request do
  include_context "logged in DfE user"

  context '#new' do
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
        :with_candidate_experience_schedule,
        :with_access_needs_support,
        :with_access_needs_detail,
        :with_disability_confident,
        :with_access_needs_policy,
        :with_experience_outline
    end

    before do
      get '/schools/on_boarding/teacher_training/new'
    end

    it 'assigns the model' do
      expect(assigns(:teacher_training)).to \
        eq Schools::OnBoarding::TeacherTraining.new
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
        :with_candidate_requirements_selection,
        :with_fees,
        :with_administration_fee,
        :with_dbs_fee,
        :with_other_fee,
        :with_only_early_years_phase,
        :with_key_stage_list,
        :with_description,
        :with_candidate_dress_code,
        :with_candidate_parking_information,
        :with_candidate_experience_schedule,
        :with_access_needs_support,
        :with_access_needs_detail,
        :with_disability_confident,
        :with_access_needs_policy,
        :with_experience_outline
    end

    let :params do
      {
        schools_on_boarding_teacher_training: teacher_training.attributes
      }
    end

    before do
      post '/schools/on_boarding/teacher_training', params: params
    end

    context 'invalid' do
      let :teacher_training do
        Schools::OnBoarding::TeacherTraining.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.teacher_training.attributes).to \
          eq teacher_training.attributes
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :teacher_training do
        FactoryBot.build :teacher_training
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.teacher_training).to \
          eq teacher_training
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
      get '/schools/on_boarding/teacher_training/edit'
    end

    it 'assigns the model' do
      expect(assigns(:teacher_training)).to eq school_profile.teacher_training
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
        schools_on_boarding_teacher_training: teacher_training.attributes
      }
    end

    before do
      patch '/schools/on_boarding/teacher_training', params: params
    end

    context 'invalid' do
      let :teacher_training do
        Schools::OnBoarding::TeacherTraining.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.teacher_training).not_to eq teacher_training
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :teacher_training do
        FactoryBot.build :teacher_training, provides_teacher_training: false
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.teacher_training).to eq teacher_training
      end

      it 'redirects to the school_profile' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
