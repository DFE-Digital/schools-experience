require 'rails_helper'

RSpec.describe "candidates/registrations/sign_ins/update.html.erb", type: :view do
  before do
    allow(view).to \
      receive(:new_candidates_school_registrations_personal_information_path).
      and_return('/stubbed')

    assign(:resend_link, '/my/resend/link')
    render
  end

  it "will notify the user their message has been sent" do
    expect(rendered).to have_css('h1', text: /Verify/i)
    expect(rendered).to \
      have_css("form[action=\"/my/resend/link\"] input[value=\"Send a new link\"]")
    expect(rendered).to \
      have_css("a[href=\"/stubbed\"]")
  end
end
