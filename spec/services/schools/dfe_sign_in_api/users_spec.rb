require "rails_helper"
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::DFESignInAPI::Users do
  include_context "logged in DfE user"

  let(:instance) { Schools::DFESignInAPI::Users.new(dfe_signin_school_ukprn) }

  before do
    allow(described_class).to receive(:enabled?).and_return(true)
  end

  describe '#organisation_users' do
    subject { instance.organisation_users }

    it do
      is_expected.to eq({
        "abc-123" => { "family_name" => "Doe", "given_name" => "John" },
        "def-456" => { "family_name" => "Smith", "given_name" => "Jane" },
      })
    end
  end

  describe "error_handling" do
    describe "when an invalid response is returned" do
      before { allow(instance).to receive(:response).and_return([]) }

      it "raises an error" do
        expect {
          instance.organisation_users
        }.to raise_error(Schools::DFESignInAPI::APIResponseError, "invalid response from users API")
      end
    end
  end
end
