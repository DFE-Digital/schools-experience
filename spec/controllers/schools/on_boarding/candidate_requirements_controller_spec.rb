require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::CandidateRequirementsController, type: :request do
  include_context "logged in DfE user"
  include_context 'with phases'

  let! :school_profile do
    create :school_profile
  end

  context '#new' do
    let! :school_profile do
      FactoryBot.create :school_profile
    end

    before do
      get '/schools/on_boarding/candidate_requirement/new'
    end

    it 'assigns the model' do
      expect(assigns(:candidate_requirement)).to eq \
        Schools::OnBoarding::CandidateRequirement.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let! :school_profile do
      FactoryBot.create :school_profile
    end

    let :params do
      {
        schools_on_boarding_candidate_requirement: candidate_requirement.attributes
      }
    end

    before do
      post '/schools/on_boarding/candidate_requirement', params: params
    end

    context 'invalid' do
      let :candidate_requirement do
        Schools::OnBoarding::CandidateRequirement.new
      end

      it 'doesnt update the school_profile' do
        expect(school_profile.reload.candidate_requirement).to eq \
          candidate_requirement
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :candidate_requirement do
        FactoryBot.build :candidate_requirement
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.candidate_requirement).to eq \
          candidate_requirement
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to new_schools_on_boarding_fees_path
      end
    end
  end

  context '#edit' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    before do
      get '/schools/on_boarding/candidate_requirement/edit'
    end

    it 'assigns the model' do
      expect(assigns(:candidate_requirement)).to \
        eq school_profile.candidate_requirement
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
        schools_on_boarding_candidate_requirement: \
          candidate_requirement.attributes
      }
    end

    before do
      patch '/schools/on_boarding/candidate_requirement', params: params
    end

    context 'invalid' do
      let :candidate_requirement do
        Schools::OnBoarding::CandidateRequirement.new
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end

      it "doesn't update the school_profile" do
        expect(school_profile.reload.candidate_requirement).not_to \
          eq candidate_requirement
      end
    end

    context 'valid' do
      let :candidate_requirement do
        FactoryBot.build \
          :candidate_requirement,
          requirements: !school_profile.candidate_requirement.requirements
      end

      it 'updates the school_profile' do
        expect(school_profile.reload.candidate_requirement).to \
          eq candidate_requirement
      end

      it 'redirects to the school_profile' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end
  end
end
