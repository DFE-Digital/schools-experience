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

  describe "when the rate limit store is unavailable" do
    before do
      allow(Rack::Attack.cache).to receive(:count).and_raise(Errno::ETIMEDOUT)
      allow(Sentry).to receive(:capture_exception)
    end

    it "lets the request through and reports the error" do
      key = Candidates::Feedback.model_name.param_key
      post candidates_feedbacks_path,
           params: { key => attributes_for(:candidates_feedback) },
           headers: { "REMOTE_ADDR" => ip }

      expect(response.status).not_to eq(301)
      expect(response).not_to have_http_status(:internal_server_error)
      expect(Sentry).to have_received(:capture_exception)
        .with(an_instance_of(Errno::ETIMEDOUT), level: :warning)
    end
  end

  describe "registrations endpoints rate limiting" do
    before do
      allow(Candidates::Registrations::ConfirmationEmailsController).to receive(:new).and_wrap_original do |original, *args|
        original.call(*args).tap do |controller|
          allow(controller).to receive(:current_registration).and_return(registration_session)
        end
      end
      allow(Candidates::Registrations::SendEmailConfirmationJob).to \
        receive(:perform_later)
      allow(Candidates::Registrations::RegistrationStore.instance).to receive(:store!)
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

    it_behaves_like "an IP-based rate limited endpoint", "POST /candidates/schools/:school_id/registrations/confirmation_email", 3, 1.minute do
      def perform_request
        post candidates_school_registrations_confirmation_email_path(11_048), headers: { "REMOTE_ADDR" => ip }
      end
    end
  end
end
