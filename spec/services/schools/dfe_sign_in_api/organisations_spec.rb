require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::DFESignInAPI::Organisations do
  include_context "logged in DfE user"
  subject { Schools::DFESignInAPI::Organisations.new(user_guid) }

  before do
    allow(described_class).to receive(:enabled?).and_return(true)
    allow(ENV).to receive(:fetch).and_return('123')
  end

  describe '#schools' do
    specify 'schools should match the API request content' do
      expect(subject.schools).to eql(
        dfe_signin_school_data
          .each
          .with_object({}) do |school, h|
            h[school.fetch(:urn).to_i] = school.fetch(:name)
          end
      )
    end
  end

  describe '#urns' do
    specify 'urns should match the API request content' do
      expect(subject.urns).to match_array(dfe_signin_school_data.map { |s| s[:urn] })
    end
  end

  describe 'error_handling' do
    subject { Schools::DFESignInAPI::Organisations.new(user_guid) }

    {
      400 => Faraday::BadRequestError,
      404 => Faraday::ResourceNotFound,
      405 => Faraday::ClientError,
      500 => Faraday::ServerError,
      502 => Faraday::ServerError,
      503 => Faraday::ServerError
    }.each do |code, error|
      context code.to_s do
        before do
          stub_request(:get, "https://some-signin-host.signin.education.gov.uk/users/#{user_guid}/organisations")
            .to_return(
              status: code,
              body: dfe_signin_school_data.to_json,
              headers: {}
            )
        end

        specify "should raise a #{error} error" do
          expect { subject.urns }.to raise_error(error)
        end
      end
    end
  end
end
