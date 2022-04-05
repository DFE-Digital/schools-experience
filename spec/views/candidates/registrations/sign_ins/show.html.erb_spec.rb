require 'rails_helper'

RSpec.describe "candidates/registrations/sign_ins/show", type: :view do
  let(:verification_code) do
    Candidates::VerificationCode.new(
      email: 'test@testymctest.com',
      firstname: 'testy',
      lastname: 'mctest'
    )
  end

  before do
    assign(:verification_code, verification_code)
    assign(:email_address, verification_code.email)
    assign(:resend_link, '/my/resend/link')
    controller.request.path_parameters[:school_id] = "123"
    render
  end

  it "will notify the user their message has been sent" do
    expect(rendered).to have_css('h1', text: /already registered with us/i)
    expect(rendered).to have_css('li', text: 'test@testymctest.com')
    expect(rendered).to \
      have_css("form[action=\"/my/resend/link\"] input[value=\"Resend verification code\"]")
  end
end
