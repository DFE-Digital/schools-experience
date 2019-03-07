require 'rails_helper'

describe Candidates::Registrations::SubjectPreferencesController, type: :request do
  let! :date do
    DateTime.now
  end

  let :registration_session do
    double Candidates::Registrations::RegistrationSession,
      save: true,
      subject_preference: existing_subject_preference
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

  context 'without existing subject_preference in session' do
    let :existing_subject_preference do
      nil
    end

    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/subject_preference/new'
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end

    context '#create' do
      before do
        post '/candidates/schools/11048/registrations/subject_preference',
          params: subject_preference_params
      end

      context 'invalid' do
        let :subject_preference_params do
          {
            candidates_registrations_subject_preference: {
              degree_stage: "I don't have a degree and am not studying for one",
              degree_subject: "geology &amp; earth science",
              teaching_stage: "I’m very sure and think I’ll apply",
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
              teaching_stage: "I’m very sure and think I’ll apply",
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
              teaching_stage: "I’m very sure and think I’ll apply",
              subject_first_choice: "Astronomy",
              subject_second_choice: "History",
              urn: 11048
        end

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/background_check/new'
        end
      end
    end
  end

  context 'with existing subject_preference in session' do
    let :existing_subject_preference do
      Candidates::Registrations::SubjectPreference.new \
        degree_stage: "I don't have a degree and am not studying for one",
        degree_stage_explaination: nil,
        degree_subject: "Not applicable",
        teaching_stage: "I’m very sure and think I’ll apply",
        subject_first_choice: "Astronomy",
        subject_second_choice: "History",
        urn: 11048
    end

    context '#edit' do
      before do
        get '/candidates/schools/11048/registrations/subject_preference/edit'
      end

      it 'populates the edit form with values from the session' do
        expect(assigns(:subject_preference)).to eq existing_subject_preference
      end

      it 'renders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context '#update' do
      before do
        patch '/candidates/schools/11048/registrations/subject_preference',
          params: subject_preference_params
      end

      context 'invalid' do
        let :subject_preference_params do
          {
            candidates_registrations_subject_preference: {
              degree_stage: "I don't have a degree and am not studying for one",
              degree_subject: "Not applicable",
              teaching_stage: "I’m very sure and think I’ll apply",
              subject_first_choice: "Astrology",
              subject_second_choice: "History"
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
        let :subject_preference_params do
          {
            candidates_registrations_subject_preference: {
              degree_stage: "Other",
              degree_stage_explaination: 'Sabbatical',
              degree_subject: "History",
              teaching_stage: "I’m very sure and think I’ll apply",
              subject_first_choice: "Astronomy",
              subject_second_choice: "History"
            }
          }
        end

        it 'updates the session with the new details' do
          expect(registration_session).to have_received(:save).with \
            Candidates::Registrations::SubjectPreference.new \
              degree_stage: "Other",
              degree_stage_explaination: 'Sabbatical',
              degree_subject: "History",
              teaching_stage: "I’m very sure and think I’ll apply",
              subject_first_choice: "Astronomy",
              subject_second_choice: "History",
              urn: 11048
        end

        it 'redirects to the application preview' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/application_preview'
        end
      end
    end
  end
end
