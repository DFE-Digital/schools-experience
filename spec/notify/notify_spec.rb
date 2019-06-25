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
    before do
      allow(Rails.application.config.x).to receive(:notify_client).and_return nil
    end

    specify 'should assign email address' do
      expect(subject.to).to eql(to)
    end

    specify 'should set up a notify client with the correct API key' do
      expect(described_class.new(to: to).notify_client).to be_a(Notifications::Client)
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

  describe 'custom notify_client' do
    class StubNotification < Notify
      attr_accessor :name

      def initialize(to:, name:)
        self.name = name
        super(to: to)
      end

    private

      def template_id
        'ec830a0d-d032-4d4b-a107-xxxxyyyyzzzz'
      end

      def personalisation
        { name: name }
      end
    end

    before do
      allow(Rails.application.config.x).to receive(:notify_client).and_return NotifyFakeClient

      NotifyFakeClient.reset_deliveries!
    end

    describe '#despatch!' do
      subject { StubNotification.new(to: 'test@user.com', name: 'Test User') }

      it "should return hash of stubbed despatch" do
        expect(subject.despatch!.keys).to eq(
          %i(delivered_at template_id email_address personalisation)
        )
      end
    end

    describe '.test_deliveries' do
      before do
        StubNotification.new(to: 'test@user.com', name: 'Test User').despatch!
      end

      it "should be included in test_deliveries list" do
        expect(NotifyFakeClient.deliveries.length).to eql(1)
        expect(NotifyFakeClient.deliveries.first.keys).to eq(
          %i(delivered_at template_id email_address personalisation)
        )
      end
    end
  end
end
