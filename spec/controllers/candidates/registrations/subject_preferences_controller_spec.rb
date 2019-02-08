require 'rails_helper'

describe Candidates::Registrations::SubjectPreferencesController, type: :request do
  let! :date do
    DateTime.now
  end

  let :registration_session do
    double Candidates::Registrations::RegistrationSession, save: true
  end

  let :subjects do
    [
      { name: 'Astronomy' },
      { name: 'History' }
    ]
  end

  let :school do
    double Candidates::School, subjects: subjects
  end

  before do
    allow(DateTime).to receive(:now) { date }

    allow(Candidates::Registrations::RegistrationSession).to \
      receive(:new) { registration_session }

    allow(Candidates::School).to receive(:find) { school }
  end

  context '#new' do
    before do
      get '/candidates/schools/URN/registrations/subject_preference/new'
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    before do
      post '/candidates/schools/URN/registrations/subject_preference',
        params: subject_preference_params
    end

    context 'invalid' do
      let :subject_preference_params do
        {
          candidates_registrations_subject_preference: {
            degree_stage: "I don't have a degree and am not studying for one",
            degree_subject: "geology &amp; earth science",
            teaching_stage: "I want to become a teacher",
            subject_first_choice: "Astronomy",
            subject_second_choice: "History"
          }
        }
      end

      it 'doesnt modify the session' do
        expect(registration_session).not_to have_received(:save)
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :subject_preference_params do
        {
          candidates_registrations_subject_preference: {
            degree_stage: "I don't have a degree and am not studying for one",
            degree_subject: "Not applicable",
            teaching_stage: "I want to become a teacher",
            subject_first_choice: "Astronomy",
            subject_second_choice: "History"
          }
        }
      end

      it 'stores the subject_preference in the session' do
        expect(registration_session).to have_received(:save).with \
          Candidates::Registrations::SubjectPreference.new \
            degree_stage: "I don't have a degree and am not studying for one",
            degree_stage_explaination: nil,
            degree_subject: "Not applicable",
            teaching_stage: "I want to become a teacher",
            subject_first_choice: "Astronomy",
            subject_second_choice: "History",
            urn: 'URN'
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          '/candidates/schools/URN/registrations/background_check/new'
      end
    end
  end
end
