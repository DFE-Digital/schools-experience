require 'rails_helper'

require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::ProfilesController, type: :request do
  include_context "logged in DfE user"

  context '#show' do
    context 'with an incomplete profile' do
      let! :school_profile do
        FactoryBot.create :school_profile
      end

      context 'when dbs_requirement feature is not enabled' do
        before do
          get '/schools/on_boarding/profile'
        end

        it 'redirects to the first incompleted step' do
          expect(response).to \
            redirect_to '/schools/on_boarding/dbs_requirement/new'
        end
      end
    end

    context 'with a complete profile' do
      let! :school_profile do
        FactoryBot.create :school_profile, :completed
      end

      before do
        get '/schools/on_boarding/profile'
      end

      it 'assigns the instance variable' do
        expect(assigns(:profile)).to \
          eq Schools::OnBoarding::SchoolProfilePresenter.new(school_profile)
        expect(assigns(:confirmation)).to \
          eq Schools::OnBoarding::Confirmation.new
      end

      it 'renders the show template' do
        expect(response).to render_template :show
      end
    end
  end
end
