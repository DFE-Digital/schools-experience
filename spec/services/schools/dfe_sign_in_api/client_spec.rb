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
end
