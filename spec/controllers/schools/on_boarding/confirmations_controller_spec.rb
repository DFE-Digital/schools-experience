require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::OnBoarding::ConfirmationsController, type: :request do
  include_context "logged in DfE user"
  include_context 'with phases'

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
        expect(response).to render_template 'schools/on_boarding/profiles/show'
      end
    end

    context 'valid' do
      let :confirmation do
        FactoryBot.build :confirmation
      end

      it 'redirects the to the confirmation show path' do
        expect(response).to redirect_to schools_on_boarding_confirmation_path
      end
    end
  end
end
