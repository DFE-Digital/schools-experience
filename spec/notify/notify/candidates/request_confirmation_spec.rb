require 'rails_helper'

describe Notify::Candidates::RequestConfirmation do
  let(:email_address) { "someone@somecompany.org" }
  let(:school_name) { "Springfield Elementary School" }
  let(:confirmation_link) { "ABCDEFGHIJKLM1234567890" }

  subject do
    described_class.new(
      email_address: email_address,
      school_name: school_name,
      confirmation_link: confirmation_link
    )
  end

  specify 'should inherit from Notify' do
    expect(subject).to be_a(Notify)
  end

  describe '#template_id' do
    specify 'should be "74dc6510-c89d-4b5b-9608-075d3f2de32d"' do
      expect(subject.send(:template_id)).to eql("74dc6510-c89d-4b5b-9608-075d3f2de32d")
    end
  end

  describe 'Initialization' do
    args = {
      email_address: "someone@somecompany.org",
      school_name: "Springfield Elementary School",
      confirmation_link: "ABCDEFGHIJKLM1234567890"
    }

    args.each do |k, _|
      specify "should raise an error if supplied without #{k}" do
        expect { described_class.new(args.except(k)) }.to raise_error(ArgumentError, "missing keyword: #{k}")
      end
    end
  end

  describe 'Methods' do
    describe '#despatch!' do
      after { subject.despatch! }

      specify 'should call @notify_client.send_email with correct args' do
        expect(subject.notify_client).to receive(:send_email).with(
          template_id: subject.send(:template_id),
          email_address: email_address,
          personalisation: {
            school_name: school_name,
            confirmation_link: confirmation_link
          }
        )
      end
    end
  end
end
