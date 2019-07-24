require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::ConfirmationsController, type: :request do
  include_context "logged in DfE user"

  let! :school_profile do
    FactoryBot.create :school_profile, :completed
  end

  context '#create' do
    let :params do
      {
        schools_on_boarding_confirmation: confirmation.attributes
      }
    end

    before do
      post '/schools/on_boarding/confirmation', params: params
    end

    context 'invalid' do
      let :confirmation do
        Schools::OnBoarding::Confirmation.new acceptance: false
      end

      it 'rerenders the profile show page' do
        expect(response).to render_template 'schools/on_boarding/previews/show'
      end

      it 'does not updated the school profile' do
        expect(school_profile.reload.confirmation).to eq confirmation
      end

      it 'does not create a Bookings::Profile' do
        expect(school_profile.bookings_school.profile).to be_nil
      end
    end

    context 'valid' do
      let :confirmation do
        FactoryBot.build :confirmation
      end

      it 'redirects the to the confirmation show path' do
        expect(response).to redirect_to schools_on_boarding_confirmation_path
      end

      it 'updates the school profile' do
        expect(school_profile.reload.confirmation).to eq confirmation
      end

      it 'creates a Bookings::Profile' do
        expect(school_profile.bookings_school.profile).to be_persisted
      end
    end
  end

  context '#show' do
    context 'when the profile is incomplete' do
      before do
        get '/schools/on_boarding/confirmation'
      end

      it 'redirects to the previous step' do
        expect(response).to redirect_to schools_on_boarding_profile_path
      end
    end

    context 'when the profile is complete' do
      let :confirmation do
        FactoryBot.build :confirmation
      end

      let :params do
        { schools_on_boarding_confirmation: confirmation.attributes }
      end

      before do
        post '/schools/on_boarding/confirmation', params: params
        get '/schools/on_boarding/confirmation'
      end

      it 'renders the show template' do
        expect(response).to render_template :show
      end
    end
  end
end
