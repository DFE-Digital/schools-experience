require 'rails_helper'

describe Notify do
  let(:email_address) { 'somename@somecompany.org' }
  subject { Notify.new(email_address: email_address) }

  describe 'Attributes' do
    it { is_expected.to respond_to(:email_address) }
    it { is_expected.to respond_to(:notify_client) }
  end

  describe 'Initialization' do
    specify 'should assign email address' do
      expect(subject.email_address).to eql(email_address)
    end

    specify 'should set up a notify client with the correct API key' do
      expect(subject.notify_client).to be_a(Notifications::Client)
    end
  end

  describe 'Methods' do
    describe '#despatch!' do
      it "should fail with 'Not implemented'" do
        expect { subject.despatch! }.to raise_error('Not implemented')
      end
    end
  end
end
