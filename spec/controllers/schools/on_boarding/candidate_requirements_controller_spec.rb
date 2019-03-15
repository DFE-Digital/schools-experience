require 'rails_helper'

describe Schools::OnBoarding::CandidateRequirementsController, type: :request do
  let! :school_profile do
    Schools::SchoolProfile.create! urn: 356127
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

      it 'doesnt update the school_profile' do
        expect(school_profile.reload.candidate_requirement).to eq \
          Schools::OnBoarding::CandidateRequirement.new
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

      it 'updates the school_profile' do
        expect(school_profile.reload.candidate_requirement).to eq \
          candidate_requirement
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to new_schools_on_boarding_fees_path
      end
    end
  end
end
