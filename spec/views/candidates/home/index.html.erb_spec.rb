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
    let(:msg) { "This is a test\n\non multiple lines" }
    before { assign :candidate_application_notification, msg }
    subject { render }
    it { is_expected.to have_css('a.govuk-button', text: 'Start now') }
    it { is_expected.to have_css('#candidate-application-notification') }
    it { is_expected.to have_css('.govuk-inset-text p', text: %r(\AThis is a test\z)) }
    it { is_expected.to have_css('.govuk-inset-text p', text: %r(\Aon multiple lines\z)) }
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
