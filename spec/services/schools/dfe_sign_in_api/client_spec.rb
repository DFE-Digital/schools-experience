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

  describe 'error handling' do
    let(:testdata) { { hello: 'world' } }
    let(:apihost) { "https://some-test-api-host.signin.education.gov.uk" }

    before do
      allow(ENV).to receive(:fetch).and_return('123')

      allow(Schools::DFESignInAPI::Client).to \
        receive(:enabled?).and_return true
    end

    class TestAPI < Schools::DFESignInAPI::Client
      def data; response; end

    private

      def endpoint
        URI::HTTPS.build \
          host: "some-test-api-host.signin.education.gov.uk",
          path: '/testapi'
      end
    end

    subject { TestAPI.new.data }

    {
      400 => Faraday::ClientError,
      404 => Faraday::ResourceNotFound,
      405 => Faraday::ClientError,
      500 => Faraday::ServerError,
      502 => Faraday::ServerError,
      503 => Faraday::ServerError
    }.each do |code, error|
      context code.to_s do
        before do
          stub_request(:get, "#{apihost}/testapi")
            .to_return(
              status: code,
              body: testdata.to_json,
              headers: {}
            )
        end

        specify "should raise a #{error} error" do
          expect { subject }.to raise_error(error)
        end
      end
    end

    context 'timeouts' do
      context 'first timeout' do
        before do
          stub_request(:get, "#{apihost}/testapi")
            .to_timeout.then
            .to_return(
              status: :success,
              body: testdata.to_json,
              headers: {}
            )
        end

        it { is_expected.to eql('hello' => 'world') }
      end

      context 'second timeout' do
        before do
          stub_request(:get, "#{apihost}/testapi")
            .to_timeout.then
            .to_timeout
        end

        it 'will raise an error' do
          expect { subject }.to raise_exception Faraday::ConnectionFailed
        end
      end
    end
  end
end
