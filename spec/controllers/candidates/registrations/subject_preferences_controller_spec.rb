require 'rails_helper'

describe Candidates::Registrations::SubjectPreferencesController, type: :request do
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
      post '/candidates/schools/URN/registrations/subject_preference', params: subject_preference_params
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
        expect(session['registration']['candidates_registrations_subject_preference']).to eq(
          "degree_stage" =>  "I don't have a degree and am not studying for one",
          "degree_stage_explaination" => nil,
          "degree_subject" =>  "Not applicable",
          "teaching_stage" =>  "I want to become a teacher",
          "subject_first_choice" =>  "Astronomy",
          "subject_second_choice" =>  "History"
        )
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          '/candidates/schools/URN/registrations/background_check/new'
      end
    end
  end
end
