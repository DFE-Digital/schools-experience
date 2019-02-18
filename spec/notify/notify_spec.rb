require 'rails_helper'
require File.join(Rails.root, 'spec', 'support', 'notify_fake_client')

describe Notify do
  let(:to) { 'somename@somecompany.org' }

  before do
    stub_const(
      'Notify::API_KEY',
      ["somekey", SecureRandom.uuid, SecureRandom.uuid].join("-")
    )
  end

  before do
    allow(subject).to receive(:notify_client).and_return(NotifyFakeClient.new)
  end

  subject { Notify.new(to: to) }

  describe 'Attributes' do
    it { is_expected.to respond_to(:to) }
    it { is_expected.to respond_to(:notify_client) }
  end

  describe 'Initialization' do
    specify 'should assign email address' do
      expect(subject.to).to eql(to)
    end

    specify 'should set up a notify client with the correct API key' do
      expect(described_class.new(to: to).notify_client).to be_a(Notifications::Client)
    end

    context 'When no Notify::API_KEY is present' do
      before do
        stub_const('Notify::API_KEY', "")
      end

      specify 'should raise a NotifyAPIKeyMissing error' do
        expect { described_class.new(to: to) }.to(
          raise_error(Notify::NotifyAPIKeyMissing, "Notify API key is missing")
        )
      end
    end
  end

  describe 'Methods' do
    describe '#despatch!' do
      it "should fail with 'Not implemented'" do
        expect { subject.despatch! }.to raise_error('Not implemented')
      end
    end

    context 'Private methods' do
      describe '#personalisation' do
        it "should fail with 'Not implemented'" do
          expect { subject.send(:personalisation) }.to raise_error('Not implemented')
        end
      end

      describe '#template_id' do
        it "should fail with 'Not implemented'" do
          expect { subject.send(:template_id) }.to raise_error('Not implemented')
        end
      end
    end
  end
end
