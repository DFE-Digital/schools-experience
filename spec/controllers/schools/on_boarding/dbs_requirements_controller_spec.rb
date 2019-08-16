require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::DbsRequirementsController, type: :request do
  include_context "logged in DfE user"

  let! :school_profile do
    create :school_profile
  end

  context '#new' do
    before { get '/schools/on_boarding/dbs_requirement/new' }

    it 'assigns the model' do
      expect(assigns(:dbs_requirement)).to eq_model \
        Schools::OnBoarding::DbsRequirement.new
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    let :params do
      { schools_on_boarding_dbs_requirement: dbs_requirement.attributes }
    end

    before do
      post '/schools/on_boarding/dbs_requirement', params: params
      school_profile.reload
    end

    context 'invalid' do
      let :dbs_requirement do
        Schools::OnBoarding::DbsRequirement.new
      end

      it 'doesnt update the school profile' do
        expect(school_profile.dbs_requirement).to eq_model dbs_requirement
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :dbs_requirement do
        build :dbs_requirement
      end

      it 'updates the school profile' do
        expect(school_profile.dbs_requirement).to eq_model dbs_requirement
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          new_schools_on_boarding_candidate_requirement_path
      end
    end
  end
end
