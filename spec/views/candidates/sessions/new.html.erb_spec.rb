require 'rails_helper'

RSpec.describe "candidates/sessions/new.html.erb", type: :view do
  let(:candidates_session) { Candidates::Session.new(nil) }

  context "with unvalidated" do
    before do
      assign(:candidates_session, candidates_session)

      render
    end

    it "will show the sign in form" do
      expect(rendered).to have_css('h1', text: 'Get school experience sign in')
      expect(rendered).to have_css('p', text: /supply details below/i)
      expect(rendered).to have_css("form")
      expect(rendered).to have_css("input[name=\"candidates_session[email]\"]")
      expect(rendered).not_to have_css(".govuk-form-group--error")
    end
  end

  context "with invalid" do
    before do
      candidates_session.valid?
      assign(:candidates_session, candidates_session)

      render
    end

    it "will show the errors in the sign in form" do
      expect(rendered).to have_css('h1', text: 'Get school experience sign in')
      expect(rendered).to have_css('p', text: /supply details below/i)
      expect(rendered).to have_css("form")
      expect(rendered).to have_css(".govuk-form-group--error input[name=\"candidates_session[email]\"]")
    end
  end
end
