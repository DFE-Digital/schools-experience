require 'rails_helper'

RSpec.describe "candidates/registrations/sign_ins/show.html.erb", type: :view do
  before do
    assign(:email_address, 'test@testymctest.com')
    assign(:resend_link, '/my/resend/link')
    render
  end

  it "will notify the user their message has been sent" do
    expect(rendered).to have_css('h1', text: /have your details/i)
    expect(rendered).to have_css('li', text: 'test@testymctest.com')
    expect(rendered).to \
      have_css("form[action=\"/my/resend/link\"] input[value=\"Resend link\"]")
  end
end
