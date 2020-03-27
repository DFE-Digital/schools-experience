require 'rails_helper'

RSpec.describe "candidates/home/index.html.erb", type: :view do
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
    it { is_expected.to have_css('p', text: %r(\AThis is a test\z)) }
    it { is_expected.to have_css('p', text: %r(\Aon multiple lines\z)) }
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

  describe 'Used the service before?' do
    let(:heading_text) { 'Used the service before?' }

    context 'before phase 5' do
      before do
        allow(Feature.instance).to receive(:current_phase).and_return(4)
      end

      before { render }

      specify 'should not allow the candidate to sign in' do
        expect(rendered).not_to have_css('h2', text: heading_text)
        expect(rendered).not_to have_link('Sign in', href: candidates_dashboard_path)
      end
    end

    context 'phase 5 and above' do
      before { render }

      specify 'should allow the candidate to sign in' do
        expect(rendered).to have_css('h2', text: heading_text)
        expect(rendered).to have_link('Sign in', href: candidates_dashboard_path)
      end
    end
  end
end
