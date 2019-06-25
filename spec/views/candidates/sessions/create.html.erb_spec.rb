require 'rails_helper'

RSpec.describe "candidates/sessions/create.html.erb", type: :view do
  include_context "stubbed out Gitis"

  let(:candidates_session) do
    Candidates::Session.new(
      gitis,
      email: 'testy@mctest.com',
      firstname: 'testy',
      lastname: 'mctest',
      date_of_birth: 20.years.ago.to_date
    )
  end

  before do
    assign(:candidates_session, candidates_session)
    render
  end

  it "should explain the email has been sent" do
    expect(rendered).to have_css('h1', text: 'Verify your school experience sign in')
    expect(rendered).to have_css('p', text: /Click the link/i)
    expect(rendered).to have_css('li', text: /testy@mctest.com/)
    expect(rendered).to have_css("a[href=\"#{candidates_signin_path}\"]")
  end
end
