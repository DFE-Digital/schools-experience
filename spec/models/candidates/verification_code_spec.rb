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

  describe "#exchange" do
    let(:personal_info) { build(:personal_information) }
    let(:instance) { described_class.new(code: code) }

    subject(:exchange) { instance.exchange(personal_info) }

    context "when the code is invalid" do
      let(:code) { "123" }

      it { is_expected.to be_falsy }

      it "does not call the API" do
        expect_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).not_to \
          receive(:exchange_access_token_for_schools_experience_sign_up)
      end
    end

    context "when the code is valid" do
      include_context "api correct verification code"

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
end
