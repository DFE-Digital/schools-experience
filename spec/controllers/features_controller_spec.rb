require 'rails_helper'

describe FeatureFlagsController, type: :request do
  let(:mock_config) { JSON.parse(file_fixture("feature-flags.json").read).with_indifferent_access }

  before { allow(Feature).to receive(:config).and_return(mock_config) }

  describe '#index' do
    before { get feature_flags_path }

    subject { response.body }

    it "shows a table with the correct markers" do
      assert_response :success

      expect(subject).to include("test")
      expect(subject).to include("another_test")

      expect(subject).to include("This is a test feature flag")
      expect(subject).to include("This is another test feature flag")

      expect(subject).to include("check").exactly(5).times
      expect(subject).to include("cross").exactly(5).times
    end
  end
end
