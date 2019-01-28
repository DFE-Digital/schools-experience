require 'rails_helper'

describe Candidate::Registrations::AccountInfosController, type: :request do
  context '#new' do
    before do
      get '/candidate/registrations/account_infos/new'
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    before do
      post '/candidate/registrations/account_infos', params: account_info_params
    end

    context 'invalid' do
      let :account_info_params do
        {
          candidate_registrations_account_info: {
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
      let :account_info_params do
        {
          candidate_registrations_account_info: {
            degree_stage: "I don't have a degree and am not studying for one",
            degree_subject: "Not applicable",
            teaching_stage: "I want to become a teacher",
            subject_first_choice: "Astronomy",
            subject_second_choice: "History"
          }
        }
      end

      it 'stores the personal details in the session' do
        expect(session[:registration][:account_info]).to eq(
          "degree_stage" =>  "I don't have a degree and am not studying for one",
          "degree_stage_explaination" => nil,
          "degree_subject" =>  "Not applicable",
          "teaching_stage" =>  "I want to become a teacher",
          "subject_first_choice" =>  "Astronomy",
          "subject_second_choice" =>  "History"
        )
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to '/candidate/registrations/background_and_security_checks/new'
      end
    end
  end
end
