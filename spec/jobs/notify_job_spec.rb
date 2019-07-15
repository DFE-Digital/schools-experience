require 'rails_helper'

describe NotifyJob do
  before { ActiveJob::Base.queue_adapter = :test }
  let(:personalisation) do
    {
      school_name: "A School",
      confirmation_link: "ABC123"
    }
  end

  context '#perform_later' do
    let(:email_address) do
      'test@test.org'
    end

    let(:email) do
      NotifyEmail::CandidateMagicLink.new({ to: email_address }.merge(personalisation))
    end

    before { NotifyJob.perform_later(email) }

    specify 'should enqueue the job properly' do
      expect { NotifyJob.perform_later(email) }.to have_enqueued_job.with(
        "NotifyEmail::CandidateMagicLink",
        "test@test.org",
        personalisation.to_json
      )
    end

    specify "doesn't log pii arguments" do
      allow(ActiveJob::Base.logger).to receive :info do |&block|
        personalisation.values.each { |v| expect(block.call).not_to include v }
        expect(block.call).not_to include email_address
        expect(block.call).to include 'NotifyEmail::CandidateMagicLink'
      end

      NotifyJob.perform_later(email)
    end
  end

  context '#perform_now' do
    subject {
      described_class.new.perform(
        "NotifyEmail::CandidateMagicLink",
        "test@test.com",
        personalisation.to_json
      )
    }

    specify 'should send an email' do
      expect(subject[:delivered_at]).not_to be_nil
      expect(subject[:template_id]).to eql('a06fe38a-5f7f-4c68-8612-6aae9495a8ab')
      expect(subject[:personalisation]).to eql(personalisation)
    end
  end
end
