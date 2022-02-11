require 'rails_helper'

describe Feature do
  subject { described_class }

  let(:mock_config) { file_fixture("feature-flags.json").read }

  before { allow(File).to receive(:read).and_return(mock_config) }

  describe '#enabled?' do
    context "when feature not in config" do
      it "throws #{described_class::FeatureNotInConfigError}" do
        expect { subject.enabled?(:non_existent_flag) }.to raise_error(described_class::FeatureNotInConfigError)
      end
    end

    context "when feature in config" do
      before { allow(Rails).to receive(:env) { "production" } }

      context "when enabled in environment" do
        it "returns true" do
          expect(subject.enabled?(:test)).to be true
        end
      end

      context "when not enabled in environment" do
        it "returns false" do
          expect(subject.enabled?(:another_test)).to be false
        end
      end
    end
  end

  describe "#all" do
    let(:expected_features) do
      [
        have_attributes(name: "test", description: "This is a test feature flag", environments: %w[development test servertest staging production]),
        have_attributes(name: "another_test", description: "This is another test feature flag", environments: [])
      ]
    end

    it "returns a list of #{Feature}" do
      expect(subject.all).to match_array expected_features
    end
  end

  describe "#all_environments" do
    it "returns all configured environments" do
      expect(subject.all_environments).to match_array %w[development test servertest staging production]
    end
  end

  describe ".new" do
    context "when environment not in Rails configured environments" do
      let(:bad_environment_feature) { Feature.new("bad", "bad", %w[does_not_exist]) }

      it "raises #{Feature::IncorrectEnvironmentError} " do
        expect { bad_environment_feature }.to raise_error(Feature::IncorrectEnvironmentError)
      end
    end
  end

  describe ".enabled_for?" do
    subject { Feature.new("feature_name", "description", %w[development]) }

    context "when enabled for the environment" do
      it "returns true" do
        expect(subject.enabled_for?("development")).to be true
      end
    end

    context "when not enabled for the environment" do
      it "returns false" do
        expect(subject.enabled_for?("production")).to be false
      end
    end
  end
end
