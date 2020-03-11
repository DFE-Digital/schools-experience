require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::DFESignInAPI::Organisations do
  include_context "logged in DfE user"

  let(:uuid_map) do
    dfe_signin_school_data.each.with_object({}) do |s, uuids|
      uuids[s[:id]] = s[:urn]
    end
  end

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

  describe '#uuids' do
    specify 'uuids be hash of org uuids mapped to URNs' do
      expect(subject.uuids).to match_array uuid_map
    end
  end

  describe '#id' do
    specify "should return the organisation's id given the correct URN" do
      expect(subject.id(dfe_signin_school_urn)).to eql(dfe_signin_school_id)
    end
  end

  describe 'error_handling' do
    subject { Schools::DFESignInAPI::Organisations.new(user_guid) }

    describe 'when an invalid response is returned' do
      before do
        allow(subject).to receive(:response).and_return({})
      end

      specify 'urns should match the API request content' do
        expect { subject.urns }.to raise_error(Schools::DFESignInAPI::APIResponseError, 'invalid response from organisations API')
      end
    end
  end
end
