require 'rails_helper'

describe Feature do
  class Tester
    def self.hello
      'world'
    end
  end

  before { Feature.instance.current_phase = 10 }
  after { Feature.instance.current_phase = nil }
  subject { Feature.instance }

  describe '#until_phase' do
    it { expect(subject.until_phase(3)).to be false }
    it { expect(subject.until_phase(10)).to be true }
    it { expect(subject.until_phase(12)).to be true }

    context 'and earlier phase' do
      before { expect(Tester).not_to receive(:hello) }

      it "will not run the block" do
        subject.until_phase(3) { Tester.hello }
      end
    end

    context 'and active phase' do
      before { expect(Tester).to receive(:hello) }

      it "will run the block" do
        subject.until_phase(10) { Tester.hello }
      end
    end

    context 'and later phase' do
      before { expect(Tester).to receive(:hello) }

      it "will run the block" do
        subject.until_phase(12) { Tester.hello }
      end
    end
  end

  describe '#until' do
    it { expect(subject.until(3)).to be false }
    it { expect(subject.until(10)).to be true }
    it { expect(subject.until(12)).to be true }
  end

  describe '#from_phase' do
    it { expect(subject.from_phase(3)).to be true }
    it { expect(subject.from_phase(10)).to be true }
    it { expect(subject.from_phase(12)).to be false }

    context 'with block' do
      context 'and earlier phase' do
        before { expect(Tester).to receive(:hello) }

        it "will run the block" do
          subject.from_phase(3) { Tester.hello }
        end
      end

      context 'and active phase' do
        before { expect(Tester).to receive(:hello) }

        it "will run the block" do
          subject.from_phase(10) { Tester.hello }
        end
      end

      context 'and later phase' do
        before { expect(Tester).not_to receive(:hello) }

        it "will not run the block" do
          subject.from_phase(12) { Tester.hello }
        end
      end
    end
  end

  describe '#from' do
    it { expect(subject.from(3)).to be true }
    it { expect(subject.from(10)).to be true }
    it { expect(subject.from(12)).to be false }
  end

  describe '#only_phase' do
    it { expect(subject.only_phase(3)).to be false }
    it { expect(subject.only_phase(10)).to be true }
    it { expect(subject.only_phase(12)).to be false }

    context 'with block' do
      context 'and earlier phase' do
        before { expect(Tester).not_to receive(:hello) }

        it "will not run the block" do
          subject.only_phase(3) { Tester.hello }
        end
      end

      context 'and active phase' do
        before { expect(Tester).to receive(:hello) }

        it "will run the block" do
          subject.only_phase(10) { Tester.hello }
        end
      end

      context 'and later phase' do
        before { expect(Tester).not_to receive(:hello) }

        it "will not run the block" do
          subject.only_phase(12) { Tester.hello }
        end
      end
    end
  end

  describe '#only' do
    it { expect(subject.only_phase(3)).to be false }
    it { expect(subject.only_phase(10)).to be true }
    it { expect(subject.only_phase(12)).to be false }
  end

  describe '#active?' do
    let(:feature_flags) { 'env1 env2' }
    before do
      allow(ENV).to receive(:[]).with('FEATURE_FLAGS') { feature_flags }
      allow(Rails.application.config.x).to \
        receive(:features) { %i(config1 config2) }

      allow_any_instance_of(described_class).to receive(:use_env_var?) { true }
    end

    subject { feature_tester.active? feature }

    shared_examples "test feature sources" do
      context 'with env feature' do
        let(:feature) { 'env2' }
        it { is_expected.to be true }
      end

      context 'with config feature' do
        let(:feature) { 'config2' }
        it { is_expected.to be true }
      end

      context 'with symbol feature' do
        let(:feature) { :config2 }
        it { is_expected.to be true }
      end

      context 'with unknown feature' do
        let(:feature) { 'config3' }
        it { is_expected.to be false }
      end
    end

    context 'from instance' do
      let(:feature_tester) { described_class.instance }
      include_examples 'test feature sources'
    end

    context 'from class' do
      let(:feature_tester) { described_class }
      include_examples 'test feature sources'
    end

    context 'with comma separated env var' do
      let(:feature_flags) { 'env1,env2' }
      let(:feature_tester) { described_class.instance }
      include_examples 'test feature sources'
    end

    context 'with mixed separator separated env var' do
      let(:feature_flags) { 'env1, env2 env3' }
      let(:feature_tester) { described_class.instance }
      include_examples 'test feature sources'
    end
  end
end
