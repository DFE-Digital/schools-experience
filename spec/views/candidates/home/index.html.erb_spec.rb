require 'rails_helper'

RSpec.describe "candidates/home/index", type: :view do
  describe 'content' do
    before { render }
    it "will show the masthead text" do
      expect(rendered).to have_css("p", text: /Use this service if/)
    end

    it "will show a button" do
      expect(rendered).to have_css('a.govuk-button', text: 'Start now')
    end
  end

  context 'when deactivated' do
    let(:msg) { "This is a test\n\non multiple lines" }
    before { assign :applications_deactivated, msg }
    subject { render }
    it { is_expected.not_to have_css('a.govuk-button', text: 'Start now') }
    it { is_expected.to have_css('#candidate-applications-deactivated') }
    it { is_expected.to have_css('p', text: %r{\AThis is a test\z}) }
    it { is_expected.to have_css('p', text: %r{\Aon multiple lines\z}) }
  end

  context 'when application_notification' do
    let(:msg) { "This is a test\n\non multiple lines\n\n<a\"mailto:help@info.com\">a link</a>" }
    before do
      without_partial_double_verification do
        allow(view).to receive(:show_candidate_alert_notification?) { true }
      end

      allow(Rails.application.config.x.candidates).to \
        receive(:alert_notification).and_return msg
    end
    subject { render template: 'candidates/home/index', layout: 'layouts/application' }
    it { is_expected.to have_css('a.govuk-button', text: 'Start now') }
    it { is_expected.to have_css('#candidate-alert-notification') }
  end
end
