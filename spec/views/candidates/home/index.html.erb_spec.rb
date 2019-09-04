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
