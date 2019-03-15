require 'rails_helper'

describe Schools::OnBoarding::CandidateRequirementsController, type: :request do
  let :school_profile do
    FactoryBot.build_stubbed :school_profile
  end

  context '#new' do
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
    before do
      allow(Schools::SchoolProfile).to receive :find_or_create_by! do
        school_profile
      end

      allow(school_profile).to receive :update!

      post '/schools/on_boarding/candidate_requirement', params: params
    end

    context 'invalid' do
      let :params do
        {
          schools_on_boarding_candidate_requirement: {
            dbs_requirement: 'nah'
          }
        }
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :candidate_requirement do
        FactoryBot.build :candidate_requirement
      end

      let :params do
        {
          schools_on_boarding_candidate_requirement: candidate_requirement.attributes
        }
      end

      it 'updates the model' do
        expect(school_profile).to have_received(:update!).with \
          candidate_requirement: candidate_requirement
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to new_schools_on_boarding_fees_path
      end
    end
  end
end
