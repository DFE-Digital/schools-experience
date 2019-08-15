require 'rails_helper'

describe Candidates::Registrations::BackgroundChecksController, type: :request do
  include_context 'Stubbed current_registration'

  before do
    FactoryBot.create :bookings_school, urn: 11048
  end

  context 'without existing background_check in session' do
    let :registration_session do
      FactoryBot.build :registration_session, with: %i(
        personal_information
        contact_information
        education
        teaching_preference
        placement_preference
      )
    end

    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/background_check/new'
      end

      it 'renders the new form' do
        expect(response).to render_template :new
      end
    end

    context '#create' do
      let :background_check_params do
        {
          candidates_registrations_background_check: \
            background_check.attributes
        }
      end

      before do
        post '/candidates/schools/11048/registrations/background_check/',
          params: background_check_params
      end

      context 'invalid' do
        let :background_check do
          Candidates::Registrations::BackgroundCheck.new
        end

        it 'doesnt modify the session' do
          expect { registration_session.background_check }.to raise_error \
            Candidates::Registrations::RegistrationSession::StepNotFound
        end

        it 'rerenders the new form' do
          expect(response).to render_template :new
        end
      end

      context 'valid' do
        let :background_check do
          FactoryBot.build :background_check
        end

        it 'stores the dbs check in the session' do
          expect(registration_session.background_check).to \
            eq_model background_check
        end

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/application_preview'
        end
      end
    end
  end

  context 'with existing background check in gitis' do
    include_context 'candidate signin'

    let :registration_session do
      FactoryBot.build :gitis_registration_session,
        gitis_contact: gitis_contact,
        with: %i(
          personal_information
          contact_information
          education
          teaching_preference
          placement_preference
        )
    end

    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/background_check/new'
      end

      it 'populates the form with the values from gitis' do
        expect(assigns(:background_check)).to have_attributes \
          has_dbs_check: gitis_contact.dfe_hasdbscertificate
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end
  end

  context 'with existing background check in session' do
    let :registration_session do
      FactoryBot.build :gitis_registration_session, with: %i(
        personal_information
        contact_information
        education
        teaching_preference
        placement_preference
      )
    end

    let :existing_background_check do
      FactoryBot.build :background_check
    end

    before do
      registration_session.save existing_background_check
    end

    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/background_check/new'
      end

      it 'populates the new form with values from the session' do
        expect(assigns(:background_check)).to eq_model existing_background_check
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end

    context '#edit' do
      before do
        get '/candidates/schools/11048/registrations/background_check/edit'
      end

      it 'populates the edit form with values from the session' do
        expect(assigns(:background_check)).to eq existing_background_check
      end

      it 'renders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context '#update' do
      let :background_check_params do
        {
          candidates_registrations_background_check: \
            background_check.attributes
        }
      end

      before do
        patch '/candidates/schools/11048/registrations/background_check',
          params: background_check_params
      end

      context 'invalid' do
        let :background_check do
          Candidates::Registrations::BackgroundCheck.new
        end

        it 'doesnt modify the session' do
          expect(registration_session.background_check).to \
            eq_model existing_background_check
        end

        it 'rerenders the edit form' do
          expect(response).to render_template :edit
        end
      end

      context 'valid' do
        let :background_check do
          FactoryBot.build :background_check, has_dbs_check: false
        end

        it 'updates the session with the new details' do
          expect(registration_session.background_check).to \
            eq_model background_check
        end

        it 'redirects to the application preview' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/application_preview'
        end
      end
    end
  end
end
