require 'rails_helper'

describe Candidates::Registrations::PlacementPreferencesController, type: :request do
  let! :date do
    DateTime.now
  end

  let! :tomorrow do
    date.tomorrow
  end

  let :registration_session do
    double Candidates::Registrations::RegistrationSession,
      save: true,
      placement_preference: existing_placement_preference
  end

  before do
    allow(DateTime).to receive(:now) { date }

    allow(Candidates::Registrations::RegistrationSession).to \
      receive(:new) { registration_session }
  end

  context 'without existing placement_preference in session' do
    let :existing_placement_preference do
      nil
    end

    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/placement_preference/new'
      end

      it 'responds with 200' do
        expect(response.status).to eq 200
      end

      it 'renders the new form' do
        expect(response.body).to render_template :new
      end
    end

    context '#create' do
      before do
        post '/candidates/schools/11048/registrations/placement_preference',
          params: placement_preference_params
      end

      context 'invalid' do
        let :placement_preference_params do
          {
            candidates_registrations_placement_preference: {
              date_start: tomorrow
            }
          }
        end

        it 'doesnt modify the session' do
          expect(registration_session).not_to have_received(:save)
        end

        it 'rerenders the new form' do
          expect(response.body).to render_template :new
        end
      end

      context 'valid' do
        let :placement_preference_params do
          {
            candidates_registrations_placement_preference: {
              date_start: tomorrow,
              date_end: (tomorrow + 3.days),
              objectives: 'Become a teacher',
              access_needs: false
            }
          }
        end

        it 'stores the placement_preference details in the session' do
          expect(registration_session).to have_received(:save).with \
            Candidates::Registrations::PlacementPreference.new \
              date_start: tomorrow,
              date_end: (tomorrow + 3.days),
              objectives: 'Become a teacher',
              access_needs: false
        end

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/contact_information/new'
        end
      end
    end
  end

  context 'with existing placement_preference in session' do
    let :existing_placement_preference do
      Candidates::Registrations::PlacementPreference.new \
        date_start: tomorrow,
        date_end: (tomorrow + 3.days),
        objectives: 'Become a teacher',
        access_needs: false
    end

    context '#edit' do
      before do
        get '/candidates/schools/11048/registrations/placement_preference/edit'
      end

      it 'populates the edit form with values from the session' do
        expect(assigns(:placement_preference)).to eq \
          existing_placement_preference
      end

      it 'renders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context '#update' do
      before do
        patch '/candidates/schools/11048/registrations/placement_preference',
          params: placement_preference_params
      end

      context 'invalid' do
        let :placement_preference_params do
          {
            candidates_registrations_placement_preference: {
              date_start: nil,
              date_end: (tomorrow + 3.days),
              objectives: 'Become a teacher',
              access_needs: false
            }
          }
        end

        it 'doesnt modify the session' do
          expect(registration_session).not_to have_received(:save)
        end

        it 'rerenders the edit template' do
          expect(response).to render_template :edit
        end
      end

      context 'valid' do
        let :placement_preference_params do
          {
            candidates_registrations_placement_preference: {
              date_start: tomorrow,
              date_end: (tomorrow + 3.days),
              objectives: 'I would like to become a teacher',
              access_needs: false
            }
          }
        end

        it 'updates the session with the new details' do
          expect(registration_session).to have_received(:save).with \
            Candidates::Registrations::PlacementPreference.new \
              date_start: tomorrow,
              date_end: (tomorrow + 3.days),
              objectives: 'I would like to become a teacher',
              access_needs: false
        end

        it 'redirects to the application preview' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/application_preview'
        end
      end
    end
  end
end
