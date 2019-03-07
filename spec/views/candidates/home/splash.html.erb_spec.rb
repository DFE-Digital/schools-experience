require 'rails_helper'

RSpec.describe "candidates/home/splash.html.erb", type: :view do
  before { render }

  it "will show the masthead text" do
    expect(rendered).to have_css("div.govuk-se-masthead", count: 1)
  end

  it "will show a button" do
    expect(rendered).to have_css('a.govuk-se-button--start', text: 'Continue')
  end
end
