require 'rails_helper'

RSpec.describe "candidates/sessions/update.html.erb", type: :view do
  before { render }

  it "should explain the session token is invalid" do
    expect(rendered).to have_css('h1', text: 'Sign in link has expired')
    expect(rendered).to have_css('p', text: /sign in link has expired/)
    expect(rendered).to have_css("a[href=\"#{candidates_signin_path}\"]")
  end
end
