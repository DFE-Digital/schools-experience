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
    context '#show' do
      let! :school_profile do
        FactoryBot.create :school_profile, :completed
      end

      before do
        get '/schools/on_boarding/profile'
      end

      it 'assigns the instance variable' do
        expect(assigns(:profile)).to \
          eq Schools::OnBoarding::SchoolProfilePresenter.new(school_profile)
      end

      it 'renders the show template' do
        expect(response).to render_template :show
      end
    end

    context '#publish' do
      context 'when the school is onboarded' do
        let(:bookings_profile) do
          FactoryBot.create :bookings_profile
        end

        let!(:school_profile) do
          FactoryBot.create :school_profile, :completed
        end

        before do
          school_profile.bookings_school.profile = bookings_profile
          school_profile.update(description_details: 'new description')

          get schools_on_boarding_profile_publish_path
        end

        it 'publishes the changes' do
          profile = school_profile.reload.bookings_school.profile

          expect(profile.description_details).to eq('new description')
        end

        it 'redirects the to the publish confirmation page' do
          expect(response).to redirect_to schools_on_boarding_profile_publish_confirmation_path
        end
      end

      context 'when the school is not onboarded' do
        let!(:school_profile) do
          FactoryBot.create :school_profile, :completed
        end

        before do
          school_profile.update(description_details: 'new description')

          get schools_on_boarding_profile_publish_path
        end

        it 'does not publishes the profile' do
          expect(school_profile.reload.bookings_school.profile).to be_nil
        end

        it 'redirects the to the confirmation show path' do
          expect(response).to redirect_to schools_on_boarding_profile_publish_confirmation_path
        end
      end
    end
  end
end
