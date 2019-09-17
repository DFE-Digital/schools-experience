require 'rails_helper'

describe Schools::DFESignInAPI::Client do
  describe '.enabled?' do
    context 'when all required environment variables are present' do
      before do
        allow(ENV).to receive(:[]).and_return('abc')
      end

      specify 'should be enabled' do
        expect(described_class).to be_enabled
      end
    end
  end

  describe '.enabled?' do
    context 'when all required environment variables are present' do
      before do
        allow(ENV).to receive(:[]).and_return('')
      end

      specify 'should be disabled' do
        expect(described_class).not_to be_enabled
      end
    end
  end
end
