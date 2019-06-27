require 'rails_helper'

RSpec.describe "candidates/home/index.html.erb", type: :view do
  before { render }

  it "will show the masthead text" do
    expect(rendered).to have_css("p", text: /Use this service if/)
  end

  it "will show a button" do
    expect(rendered).to have_css('a.govuk-button', text: 'Start now')
  end
end
