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

  describe 'Template' do
    subject { described_class.new(to: to, **personalisation) }
    let(:template_path) { [Rails.root, "app", "notify", "notify_email"] }

    let(:template) do
      File.read(
        Dir.glob(
          "#{File.join(template_path)}/*#{subject.send(:template_id)}.md"
        ).first
      )
    end

    specify "every initialization paramater should appear in the template" do
      template_params = template
        .scan(/\(\((\w+)\)\)/)
        .flatten
        .sort
        .uniq
        .map(&:to_s)

      initialization_params = subject
        .method(:initialize)
        .parameters
        .map(&:last)
        .reject { |ip| ip == :to }
        .map(&:to_s)

      expect(initialization_params).to match_array(template_params)
    end
  end
end


shared_examples_for "email template from application preview" do |school_admin_included|
  describe ".from_application_preview" do
    before do
      stub_const(
        'Notify::API_KEY',
        ["somekey", SecureRandom.uuid, SecureRandom.uuid].join("-")
      )
    end

    specify { expect(described_class).to respond_to(:from_application_preview) }

    let!(:school) { create(:bookings_school, urn: 11048) }
    let(:rs) { build(:registration_session) }
    let(:to) { "morris.szyslak@moes.net" }
    let(:ap) { Candidates::Registrations::ApplicationPreview.new(rs) }

    subject { described_class.from_application_preview(to, ap) }

    it { is_expected.to be_a(described_class) }

    context 'correctly assigning attributes' do
      specify 'candidate_address is correctly-assigned' do
        expect(subject.candidate_address).to eql(ap.full_address)
      end

      specify 'candidate_dbs_check_document is correctly-assigned' do
        expect(subject.candidate_dbs_check_document).to eql(ap.dbs_check_document)
      end

      specify 'candidate_degree_stage is correctly-assigned' do
        expect(subject.candidate_degree_stage).to eql(ap.degree_stage)
      end

      specify 'candidate_email_address is correctly-assigned' do
        expect(subject.candidate_email_address).to eql(ap.email_address)
      end

      specify 'candidate_name is correctly-assigned' do
        expect(subject.candidate_name).to eql(ap.full_name)
      end

      specify 'candidate_phone_number is correctly-assigned' do
        expect(subject.candidate_phone_number).to eql(ap.telephone_number)
      end

      specify 'candidate_teaching_stage is correctly-assigned' do
        expect(subject.candidate_teaching_stage).to eql(ap.teaching_stage)
      end

      specify 'candidate_teaching_subject_first_choice is correctly-assigned' do
        expect(subject.candidate_teaching_subject_first_choice).to eql(ap.teaching_subject_first_choice)
      end

      specify 'candidate_teaching_subject_second_choice is correctly-assigned' do
        expect(subject.candidate_teaching_subject_second_choice).to eql(ap.teaching_subject_second_choice)
      end

      specify 'placement_finish_date is correctly-assigned' do
        expect(subject.placement_finish_date).to eql(ap.placement_date_end)
      end

      specify 'placement_outcome is correctly-assigned' do
        expect(subject.placement_outcome).to eql(ap.placement_outcome)
      end

      specify 'placement_start_date is correctly-assigned' do
        expect(subject.placement_start_date).to eql(ap.placement_date_start)
      end

      specify 'school_name is correctly-assigned' do
        expect(subject.school_name).to eql(ap.school)
      end

      if school_admin_included
        specify 'school_admin_name is correctly-assigned' do
          expect(subject.school_admin_name).to match(/PLACEHOLDER/)
        end
      end
    end
  end
end
