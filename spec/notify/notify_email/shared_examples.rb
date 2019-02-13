require 'rails_helper'

shared_examples_for "email template" do |template_id, personalisation|
  let(:to) { "someone@somecompany.org" }

  subject do
    described_class.new(to: to, **personalisation)
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

  describe 'Methods' do
    describe '#despatch!' do
      after { subject.despatch! }

      specify 'should call @notify_client.send_email with correct args' do
        expect(subject.notify_client).to receive(:send_email).with(
          template_id: subject.send(:template_id),
          email_address: to,
          personalisation: personalisation
        )
      end
    end
  end
end
