require 'rails_helper'

describe NotifyService do
  let(:email_address) { 'test@example.com' }
  let(:template_id) { '123' }
  let(:personalisation) { { name: 'Testy McTest' } }
  let(:api_key) { ["somekey", SecureRandom.uuid, SecureRandom.uuid].join("-") }
  let(:endpoint) { "https://api.notifications.service.gov.uk/v2/notifications/email" }

  let :body do
    {
      template_id: template_id,
      email_address: email_address,
      personalisation: personalisation
    }.to_json
  end

  let :response do
    { status: 200, body: "{}", headers: {} }
  end

  before do
    stub_const 'NotifyService::API_KEY', api_key
    allow(described_class.instance).to receive(:notification_class) { Notifications::Client }
    stub_request(:post, endpoint).with(body: body).to_return(response)
  end

  context '#send_email' do
    before do
      described_class.instance.send_email \
        template_id: template_id,
        email_address: email_address,
        personalisation: personalisation
    end

    it 'despatches to the notification service' do
      expect(WebMock).to have_requested(:post, endpoint).with(body: body)
    end
  end
end
