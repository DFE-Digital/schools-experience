require 'rails_helper'

describe Candidates::Registrations::AddressesController, type: :request do
  let! :date do
    DateTime.now
  end

  let :registration_session do
    double Candidates::Registrations::RegistrationSession,
      save: true,
      address: existing_address
  end

  before do
    allow(DateTime).to receive(:now) { date }

    allow(Candidates::Registrations::RegistrationSession).to \
      receive(:new) { registration_session }
  end

  context 'without existing address in session' do
    let :existing_address do
      nil
    end

    context '#new' do
      before do
        get '/candidates/schools/URN/registrations/address/new'
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
        post '/candidates/schools/URN/registrations/address',
          params: address_params
      end

      context 'invalid' do
        let :address_params do
          {
            candidates_registrations_address: {
              building: 'Test house',
              street: 'Test street',
              town_or_city: 'Test Town',
              county: 'Testshire',
              postcode: 'TE57 1NG'
            }
          }
        end

        it 'rerenders the new template' do
          expect(response).to render_template :new
        end

        it 'doesnt modify the session' do
          expect(registration_session).not_to have_received(:save)
        end
      end

      context 'valid' do
        let :address_params do
          {
            candidates_registrations_address: {
              building: 'Test house',
              street: 'Test street',
              town_or_city: 'Test Town',
              county: 'Testshire',
              postcode: 'TE57 1NG',
              phone: '01234567890',
            }
          }
        end

        it 'stores the address details in the session' do
          expect(registration_session).to have_received(:save).with \
            Candidates::Registrations::Address.new \
              building: 'Test house',
              street: 'Test street',
              town_or_city: 'Test Town',
              county: 'Testshire',
              postcode: 'TE57 1NG',
              phone: '01234567890'
        end

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            '/candidates/schools/URN/registrations/subject_preference/new'
        end
      end
    end
  end

  context 'with existing address in session' do
    let :existing_address do
      Candidates::Registrations::Address.new \
        building: 'Test house',
        street: 'Test street',
        town_or_city: 'Test Town',
        county: 'Testshire',
        postcode: 'TE57 1NG',
        phone: '01234567890'
    end

    context '#edit' do
      before do
        get '/candidates/schools/URN/registrations/address/edit'
      end

      it 'populates the edit form with values from the session' do
        expect(assigns(:address)).to eq existing_address
      end

      it 'renders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context '#update' do
      before do
        patch '/candidates/schools/URN/registrations/address',
          params: address_params
      end

      context 'invalid' do
        let :address_params do
          {
            candidates_registrations_address: {
              building: 'Test house',
              street: 'Test street',
              town_or_city: 'Test Town',
              county: 'Testshire',
              postcode: 'TE57 1NG',
              phone: ''
            }
          }
        end

        it 'doesnt modify the session' do
          expect(registration_session).not_to have_received(:save)
        end

        it 'rerenders the edit form' do
          expect(response).to render_template :edit
        end
      end

      context 'valid' do
        let :address_params do
          {
            candidates_registrations_address: {
              building: 'New house',
              street: 'Test street',
              town_or_city: 'Test Town',
              county: 'Testshire',
              postcode: 'TE57 1NG',
              phone: '01234567890'
            }
          }
        end

        it 'updates the session with the new details' do
          expect(registration_session).to have_received(:save).with \
            Candidates::Registrations::Address.new \
              building: 'New house',
              street: 'Test street',
              town_or_city: 'Test Town',
              county: 'Testshire',
              postcode: 'TE57 1NG',
              phone: '01234567890'
        end

        it 'redirects to the application preview' do
          expect(response).to redirect_to \
            '/candidates/schools/URN/registrations/application_preview'
        end
      end
    end
  end
end
