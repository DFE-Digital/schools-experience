require 'rails_helper'
require File.join(Rails.root, 'spec', 'support', 'notify_fake_client')

shared_examples_for "email template" do |template_id, personalisation|
  let(:to) { "someone@somecompany.org" }

  before do
    stub_const(
      'Notify::API_KEY',
      ["somekey", SecureRandom.uuid, SecureRandom.uuid].join("-")
    )
  end

  subject do
    described_class.new(to: to, **personalisation)
  end

  before do
    allow(subject).to receive(:notify_client).and_return(NotifyFakeClient.new)
  end

  specify 'should inherit from Notify' do
    expect(subject).to be_a(Notify)
  end

  describe '#template_id' do
    specify "should be #{template_id}" do
      expect(subject.send(:template_id)).to eql(template_id)
    end
  end

  describe 'Initialization' do
    personalisation.each do |k, _|
      specify "should raise an error if supplied without :#{k}" do
        { to: to }.merge(personalisation.except(k)).tap do |args|
          expect { described_class.new(args) }.to raise_error(ArgumentError, "missing keyword: #{k}")
        end
      end
    end
  end

  describe 'Attributes' do
    personalisation.each do |k, _|
      specify "should respond to #{k}" do
        expect(subject).to respond_to(k)
      end
    end
  end

  describe 'Methods' do
    describe '#despatch!' do
      context 'successfully sending emails' do
        after { subject.despatch! }

        specify 'should call @notify_client.send_email with correct args' do
          expect(subject.notify_client).to receive(:send_email).with(
            template_id: subject.send(:template_id),
            email_address: to,
            personalisation: personalisation
          )
        end
      end

      # https://docs.notifications.service.gov.uk/ruby.html#error-codes
      context 'when Notify is unable to process a request' do
        let(:nc) { subject.notify_client }
        let(:error_message) { "500, something went wrong" }
        before do
          allow(nc).to receive(:send_email).and_raise(
            Notifications::Client::ServerError,
            OpenStruct.new(body: error_message)
          )
        end

        specify 'should raise a RetryableError' do
          expect { subject.despatch! }.to raise_error(Notify::RetryableError, error_message)
        end
      end
    end
  end
end
