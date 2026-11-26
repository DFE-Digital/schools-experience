require "rails_helper"

describe Candidates::VerificationCode do
  it { is_expected.to respond_to :code }

  describe "code" do
    it { is_expected.to allow_value("000000").for :code }
    it { is_expected.to allow_value(" 123456").for :code }
    it { is_expected.not_to allow_value("abc123").for :code }
    it { is_expected.not_to allow_value("1234567").for :code }
    it { is_expected.not_to allow_value("12345").for :code }
  end

  describe "API methods" do
    let(:personal_info) { build(:personal_information) }
    let(:instance) do
      described_class.new(
        code: code,
        firstname: personal_info.first_name,
        lastname: personal_info.last_name,
        email: personal_info.email
      )
    end

    describe "#exchange" do
      subject(:exchange) { instance.exchange }

      context "when the code is invalid" do
        let(:code) { "123" }

        before do
          allow(GetIntoTeachingApiClient::SchoolsExperienceApi).to receive(:new).and_call_original
        end

        it { is_expected.to be_falsy }

        it "does not call the API" do
          exchange

          expect(GetIntoTeachingApiClient::SchoolsExperienceApi).not_to have_received(:new)
        end
      end

      context "when the code is valid" do
        include_context "when the API returns a correct verification code for personal information"

        it { is_expected.to eq(sign_up) }

        context "when the code is incorrect" do
          include_context "when the API returns an incorrect verification code"

          it { is_expected.to be_nil }

          it "adds an error to the model" do
            exchange
            expect(instance.errors).to be_added(:code, :invalid)
          end
        end
      end

      context "when gitis contact is missing the first or last name" do
        include_context "when the API returns a correct verification code for personal information without a name"

        it "updates the first name" do
          expect(exchange.first_name).not_to be_empty
        end

        it "updates the last name" do
          expect(exchange.last_name).not_to be_empty
        end
      end
    end

    describe "#issue_verification_code" do
      subject { instance.issue_verification_code }

      let(:code) { nil }

      let(:request) do
        GetIntoTeachingApiClient::ExistingCandidateRequest.new(
          email: personal_info.email,
          first_name: personal_info.first_name,
          last_name: personal_info.last_name
        )
      end

      let(:candidates_api_client) { instance_double(GetIntoTeachingApiClient::CandidatesApi) }

      before do
        allow(GetIntoTeachingApiClient::CandidatesApi).to receive(:new).and_return(candidates_api_client)
        allow(candidates_api_client).to receive(:create_candidate_access_token).with(request)
      end

      it { is_expected.to be_truthy }

      context "when the user cannot be matched back" do
        before do
          allow(candidates_api_client).to receive(:create_candidate_access_token)
              .with(request).and_raise(GetIntoTeachingApiClient::ApiError)
        end

        it { is_expected.to be_falsy }
      end
    end
  end
end
