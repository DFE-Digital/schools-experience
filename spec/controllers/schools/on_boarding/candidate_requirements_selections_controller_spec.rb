require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::CandidateRequirementsSelectionsController, type: :request do
  include_context "logged in DfE user"

  let! :school_profile do
    FactoryBot.create :school_profile,
      :with_dbs_requirement,
      :with_candidate_requirements_choice
  end

  context '#new' do
    before do
      get '/schools/on_boarding/candidate_requirements_selection/new'
    end

    it 'assigns the model' do
      expect(assigns(:candidate_requirements_selection)).to eq \
        Schools::OnBoarding::CandidateRequirementsSelection.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :params do
      {
        schools_on_boarding_candidate_requirements_selection: \
          candidate_requirements_selection.attributes
      }
    end

    before do
      post '/schools/on_boarding/candidate_requirements_selection/',
        params: params
    end

    context 'invalid' do
      let :candidate_requirements_selection do
        Schools::OnBoarding::CandidateRequirementsSelection.new
      end

      it 'doesnt update the school profile' do
        expect(school_profile.reload.candidate_requirements_selection).to eq \
          candidate_requirements_selection
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :candidate_requirements_selection do
        build :candidate_requirements_selection
      end

      it 'updates the school profile' do
        expect(school_profile.reload.candidate_requirements_selection).to eq \
          candidate_requirements_selection
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to new_schools_on_boarding_fees_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, \
        :completed, :with_candidate_requirements_selection,
        :with_candidate_requirements_choice
    end

    before do
      get '/schools/on_boarding/candidate_requirements_selection/edit'
    end

    it 'assigns the model' do
      expect(assigns(:candidate_requirements_selection)).to \
        eq school_profile.candidate_requirements_selection
    end

    it 'renders the edit template' do
      expect(response).to render_template :edit
    end
  end

  context '#update' do
    let! :school_profile do
      FactoryBot.create :school_profile, \
        :completed, :with_candidate_requirements_selection,
        :with_candidate_requirements_choice
    end

    let :params do
      {
        schools_on_boarding_candidate_requirements_selection: \
          candidate_requirements_selection.attributes
      }
    end

    before do
      patch '/schools/on_boarding/candidate_requirements_selection',
        params: params
    end

    context 'invalid' do
      let :candidate_requirements_selection do
        Schools::OnBoarding::CandidateRequirementsSelection.new
      end

      it 'doesnt update the school_profile' do
        expect(school_profile.reload.candidate_requirements_selection).not_to \
          eq candidate_requirements_selection
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :candidate_requirements_selection do
        school_profile.candidate_requirements_selection.tap do |m|
          m.has_or_working_towards_degree = !m.has_or_working_towards_degree
        end
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.candidate_requirements_selection).to \
          eq candidate_requirements_selection
      end

      it 'redirects to the school_profile' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
