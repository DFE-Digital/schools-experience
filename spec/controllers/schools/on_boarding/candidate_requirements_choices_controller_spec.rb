require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::CandidateRequirementsChoicesController, type: :request do
  include_context "logged in DfE user"

  let! :school_profile do
    FactoryBot.create :school_profile, :with_dbs_requirement
  end

  context '#new' do
    before do
      get '/schools/on_boarding/candidate_requirements_choice/new'
    end

    it 'assigns the model' do
      expect(assigns(:candidate_requirements_choice)).to \
        eq Schools::OnBoarding::CandidateRequirementsChoice.new
    end

    it 'rerenders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :params do
      {
        schools_on_boarding_candidate_requirements_choice: \
          candidate_requirements_choice.attributes
      }
    end

    before do
      post '/schools/on_boarding/candidate_requirements_choice', params: params
    end

    context 'invalid' do
      let :candidate_requirements_choice do
        Schools::OnBoarding::CandidateRequirementsChoice.new
      end

      it 'doesnt update the school profile' do
        expect(school_profile.reload.candidate_requirements_choice).to eq \
          candidate_requirements_choice
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :candidate_requirements_choice do
        FactoryBot.build :candidate_requirements_choice
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.candidate_requirements_choice).to eq \
          candidate_requirements_choice
      end

      it 'redirects to the next_step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_candidate_requirements_selection_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/candidate_requirements_choice/edit'
    end

    it 'assigns the model' do
      expect(assigns(:candidate_requirements_choice)).to \
        eq school_profile.candidate_requirements_choice
    end

    it 'rerenders the edit template' do
      expect(response).to render_template :edit
    end
  end

  context '#update' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    let :params do
      {
        schools_on_boarding_candidate_requirements_choice: \
          candidate_requirements_choice.attributes
      }
    end

    before do
      patch '/schools/on_boarding/candidate_requirements_choice', params: params
    end

    context 'invalid' do
      let :candidate_requirements_choice do
        Schools::OnBoarding::CandidateRequirementsChoice.new
      end

      it 'doesnt update the school_profile' do
        expect(school_profile.reload.candidate_requirements_choice).not_to eq \
          candidate_requirements_choice
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :candidate_requirements_choice do
        FactoryBot.build :candidate_requirements_choice,
          has_requirements: false
      end

      it 'udates the school_profile' do
        expect(school_profile.reload.candidate_requirements_choice).to eq \
          candidate_requirements_choice
      end

      it 'redirects to the next_step' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
