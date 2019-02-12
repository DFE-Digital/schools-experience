require 'rails_helper'

describe Notify::Candidates::RequestConfirmationNotification do
  let(:to) { "someone@somecompany.org" }

  personalisation = {
    school_name: "Springfield Elementary School",
    candidate_address: "23 Railway Cuttings, East Cheam, CR3 0HD",
    candidate_dbs_check_document: "Yes",
    candidate_degree_stage: "Postgraduate",
    candidate_degree_subject: "Sociology",
    candidate_disability_needs: "None",
    candidate_email_address: "tony.hancock@bbc.co.uk",
    candidate_name: "Tony Hancock",
    candidate_phone_number: "01234 456 678",
    candidate_teaching_stage: "I want to become a teacher",
    candidate_teaching_subject_first_choice: "Sociology",
    candidate_teaching_subject_second_choice: "Philosophy",
    placement_finish_date: "2020-01-14",
    placement_outcome: "I enjoy teaching",
    placement_start_date: "2020-01-07",
  }

  let(:personalisation) { personalisation }

  subject do
    described_class.new(to: to, **personalisation)
  end

  describe '#template_id' do
    specify 'should be "8bd7e9b3-8c3f-4702-b642-1ccff32a264f"' do
      expect(subject.send(:template_id)).to eql("8bd7e9b3-8c3f-4702-b642-1ccff32a264f")
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
