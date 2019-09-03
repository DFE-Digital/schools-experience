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
end
