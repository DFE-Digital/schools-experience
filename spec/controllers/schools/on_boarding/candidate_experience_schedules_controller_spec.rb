require 'rails_helper'

require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::CandidateExperienceSchedulesController, type: :request do
  include_context "logged in DfE user"

  let(:task_progress_on_boarding) { false }

  before do
    allow(Feature).to receive(:enabled?).with(:task_progress_on_boarding)
      .and_return(task_progress_on_boarding)
  end

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
        :with_candidate_parking_information
    end

    before do
      get '/schools/on_boarding/candidate_experience_schedule/new'
    end

    it 'assigns the model' do
      expect(assigns(:candidate_experience_schedule)).to \
        eq Schools::OnBoarding::CandidateExperienceSchedule.new
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
        :with_candidate_parking_information
    end

    let :params do
      {
        schools_on_boarding_candidate_experience_schedule: \
          candidate_experience_schedule.attributes
      }
    end

    before do
      post '/schools/on_boarding/candidate_experience_schedule/', params: params
    end

    context 'invalid' do
      let :candidate_experience_schedule do
        Schools::OnBoarding::CandidateExperienceSchedule.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.candidate_experience_schedule.attributes).to \
          eq candidate_experience_schedule.attributes
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :candidate_experience_schedule do
        FactoryBot.build :candidate_experience_schedule
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.candidate_experience_schedule).to \
          eq candidate_experience_schedule
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_access_needs_support_path
      end

      context "when the task_progress_on_boarding feature is enabled" do
        let(:task_progress_on_boarding) { true }

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            new_schools_on_boarding_experience_outline_path
        end
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/candidate_experience_schedule/edit'
    end

    it 'assigns the model' do
      expect(assigns(:candidate_experience_schedule)).to \
        eq school_profile.candidate_experience_schedule
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
        schools_on_boarding_candidate_experience_schedule: \
          candidate_experience_schedule.attributes
      }
    end

    before do
      patch '/schools/on_boarding/candidate_experience_schedule/', params: params
    end

    context 'invalid' do
      let :candidate_experience_schedule do
        Schools::OnBoarding::CandidateExperienceSchedule.new
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.candidate_experience_schedule).not_to \
          eq candidate_experience_schedule
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :candidate_experience_schedule do
        FactoryBot.build \
          :candidate_experience_schedule
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.candidate_experience_schedule).to \
          eq candidate_experience_schedule
      end

      it 'redirects to the school_profile' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
