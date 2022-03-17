require 'rails_helper'

require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::ProfilesController, type: :request do
  include_context "logged in DfE user"

  context 'with an incomplete profile' do
    let! :school_profile do
      FactoryBot.create :school_profile
    end

    before do
      get '/schools/on_boarding/profile'
    end

    it 'redirects to the first incompleted step' do
      expect(response).to \
        redirect_to '/schools/on_boarding/dbs_requirement/new'
    end
  end

  context 'with a complete profile' do
    let! :school_profile do
      FactoryBot.create :school_profile, :completed
    end

    context '#show' do
      before do
        get '/schools/on_boarding/profile'
      end

      it 'assigns the instance variable' do
        expect(assigns(:profile)).to \
          eq Schools::OnBoarding::SchoolProfilePresenter.new(school_profile)
      end

      it 'renders the onboarding template' do
        expect(response).to render_template :onboarding
      end

      context "when school is onboarded" do
        let(:school) { create(:bookings_school, :onboarded) }
        let(:school_profile) { FactoryBot.create :school_profile, :completed, bookings_school: school }

        include_context "logged in DfE user for school with profile"

        it 'renders the editing template' do
          expect(response).to render_template :editing
        end
      end
    end
  end
end
