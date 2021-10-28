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
        email: personal_info.email,
        date_of_birth: personal_info.date_of_birth
      )
    end

    describe "#exchange" do
      subject(:exchange) { instance.exchange }

      context "when the code is invalid" do
        let(:code) { "123" }

        it { is_expected.to be_falsy }

        it "does not call the API" do
          expect_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).not_to \
            receive(:exchange_access_token_for_schools_experience_sign_up)
        end
      end

      context "when the code is valid" do
        include_context "api correct verification code for personal info"

        it { is_expected.to eq(sign_up) }

        context "when the code is incorrect" do
          include_context "api incorrect verification code"

          it { is_expected.to be_nil }

          it "adds an error to the model" do
            exchange
            expect(instance.errors).to be_added(:code, :invalid)
          end
        end
      end
    end

    describe "#issue_verification_code" do
      let(:code) { nil }

      let(:request) do
        GetIntoTeachingApiClient::ExistingCandidateRequest.new(
          email: personal_info.email,
          firstName: personal_info.first_name,
          lastName: personal_info.last_name,
          dateOfBirth: personal_info.date_of_birth
        )
      end

      subject { instance.issue_verification_code }

      before do
        allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to \
          receive(:create_candidate_access_token).with(request)
      end

      it { is_expected.to be_truthy }

      context "when the user cannot be matched back" do
        before do
          allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to \
            receive(:create_candidate_access_token)
              .with(request).and_raise(GetIntoTeachingApiClient::ApiError)
        end

        it { is_expected.to be_falsy }
      end
    end
  end
end
