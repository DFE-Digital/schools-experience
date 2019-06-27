Then("I should see my name in the phase banner") do
  # the name is set in School::InsecureSessionsController
  within('.govuk-phase-banner') do
    expect(page).to have_content('Martin Prince')
  end
end

Then("there should be a {string} link in the phase banner") do |link_text|
  within('.govuk-phase-banner') do
    expect(page).to have_link(link_text, href: schools_session_path)
  end
end
