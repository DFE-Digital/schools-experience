require 'rails_helper'

describe Schools::DFESignInAPI::Client do
  describe '.enabled?' do
    context 'when setting is on and all required environment variables are present' do
      before do
        allow(Rails.application.config.x).to receive(:dfe_sign_in_api_enabled).and_return(true)
        allow(ENV).to receive(:fetch).and_return('abc')
      end

      specify 'should be enabled' do
        expect(described_class).to be_enabled
      end
    end

    context 'when setting is off all required environment variables are present' do
      before do
        allow(Rails.application.config.x).to receive(:dfe_sign_in_api_enabled).and_return(false)
        allow(ENV).to receive(:fetch).and_return('abc')
      end

      specify 'should be enabled' do
        expect(described_class).not_to be_enabled
      end
    end

    context 'when all required environment variables are not present' do
      before do
        allow(ENV).to receive(:[]).and_return('')
      end

      specify 'should be disabled' do
        expect(described_class).not_to be_enabled
      end
    end
  end

  describe '.role_check_enabled?' do
    specify 'should be disabled when the client is disabled'
    specify 'should require the dfe_sign_in_api_role_check_enabled to be true'
    specify 'should require both environment variables to be present'
  end
end
