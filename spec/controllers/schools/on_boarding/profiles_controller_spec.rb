require 'rails_helper'

require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::OnBoarding::ProfilesController, type: :request do
  include_context "when a DfE user is logged in"

  context 'with an incomplete profile' do
    before do
      FactoryBot.create :school_profile
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

    describe '#show' do
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
        let(:school) { create(:bookings_school, :onboarded, urn: 123_456) }
        let(:urn) { 123_456 }
        let(:current_user_school) { school }
        let(:school_profile) { FactoryBot.create :school_profile, :completed, bookings_school: school }

        before do
          current_user_school.tap do |current_school|
            current_school.subjects << FactoryBot.create_list(:bookings_subject, 2)
            create :bookings_profile, school: current_school unless current_school.profile
          end
        end

        it 'renders the editing template' do
          expect(response).to render_template :editing
        end
      end
    end
  end
end
