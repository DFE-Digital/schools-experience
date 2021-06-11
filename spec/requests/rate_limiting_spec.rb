require "rails_helper"

describe "Rate limiting" do
  let(:ip) { "1.2.3.4" }

  it_behaves_like "an IP-based rate limited endpoint", "POST /candidates/feedbacks", 5, 1.minute do
    def perform_request
      key = Candidates::Feedback.model_name.param_key
      params = { key => attributes_for(:candidates_feedback) }
      post candidates_feedbacks_path, params: params, headers: { "REMOTE_ADDR" => ip }
    end
  end

  describe "registrations endpoints rate limiting" do
    before do
      allow_any_instance_of(Candidates::Registrations::ConfirmationEmailsController).to \
        receive(:current_registration) { registration_session }
      allow(Candidates::Registrations::SendEmailConfirmationJob).to \
        receive(:perform_later)
      allow_any_instance_of(Candidates::Registrations::RegistrationStore).to \
        receive(:store!)
    end

    let :registration_session do
      FactoryBot.build :registration_session, urn: 11_048,
                                              with: %i[
                                                personal_information
                                                contact_information
                                                education
                                                teaching_preference
                                                placement_preference
                                                background_check
                                                subject_and_date_information
                                              ]
    end

    it_behaves_like "an IP-based rate limited endpoint", "POST /candidates/schools/:school_id/registrations/confirmation_email", 5, 1.minute do
      def perform_request
        key = Candidates::Registrations::PrivacyPolicy.model_name.param_key
        params = { key => { acceptance: '1' } }

        post candidates_school_registrations_confirmation_email_path(11_048), params: params, headers: { "REMOTE_ADDR" => ip }
      end
    end
  end
end
