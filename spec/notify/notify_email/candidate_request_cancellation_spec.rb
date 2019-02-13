require 'rails_helper'

describe NotifyEmail::CandidateRequestCancellation do
  let(:to) { "someone@somecompany.org" }

  personalisation = {
    school_name: "Springfield Elementary School",
    candidate_name: "Nelson Muntz",
    start_date: "2020-04-05",
    finish_date: "2020-04-12"
  }

  let(:personalisation) { personalisation }

  subject do
    described_class.new(to: to, **personalisation)
  end

  specify 'should inherit from Notify' do
    expect(subject).to be_a(Notify)
  end

  describe '#template_id' do
    specify 'should be "17e87d47-afe9-477d-969d-8a4ab67280f3"' do
      expect(subject.send(:template_id)).to eql("17e87d47-afe9-477d-969d-8a4ab67280f3")
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
