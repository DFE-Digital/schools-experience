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
    before { allow(Feature).to receive(:active?).with(:rolecheck) { true } }

    context 'when the client is disabled' do
      before { allow(subject).to receive(:enabled?).and_return(false) }
      before { allow(ENV).to receive(:fetch).and_return(true) }

      specify 'should be disabled' do
        expect(subject).not_to be_role_check_enabled
      end
    end

    context 'when the client is enabled' do
      subject { described_class }
      before { allow(subject).to receive(:enabled?).and_return(true) }
      before { allow(Rails.application.config.x).to receive(:dfe_sign_in_api_role_check_enabled).and_return(true) }

      context 'when role check is disabled' do
        before { allow(Feature).to receive(:active?).with(:rolecheck) { false } }

        context 'when the DfE Sign-in role and service environment variables are absent' do
          before { allow(ENV).to receive(:fetch).and_return(nil) }

          specify 'should be disabled' do
            expect(subject).not_to be_role_check_enabled
          end
        end
      end

      context 'when role check is enabled' do
        context 'when the DfE Sign-in role and service environment variables are absent' do
          before { allow(ENV).to receive(:fetch).and_return(nil) }

          specify 'should be disabled' do
            expect(subject).not_to be_role_check_enabled
          end
        end

        context 'when the DfE Sign-in role and service environment variables are present' do
          before { allow(ENV).to receive(:fetch).and_return('yes') }

          specify 'should be enabled' do
            expect(subject).to be_role_check_enabled
          end
        end
      end
    end
  end
end
