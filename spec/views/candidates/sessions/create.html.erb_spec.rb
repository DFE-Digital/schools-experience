require 'rails_helper'

RSpec.describe "candidates/sessions/create", type: :view do
  let(:verification_code) do
    Candidates::VerificationCode.new(
      email: 'testy@mctest.com',
      firstname: 'testy',
      lastname: 'mctest'
    )
  end

  before do
    assign(:verification_code, verification_code)
    render
  end

  it "should explain the email has been sent" do
    expect(rendered).to have_css('h1', text: 'Verify your school experience sign in')
    expect(rendered).to have_css('p', text: /enter the verification code/i)
    expect(rendered).to have_css('li', text: /testy@mctest.com/)
    expect(rendered).to have_css("a[href=\"#{candidates_signin_path}\"]")
  end
end
