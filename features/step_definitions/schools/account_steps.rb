Then("I should see my name in the phase banner") do
  # the name is set in School::InsecureSessionsController
  within('.govuk-phase-banner') do
    expect(page).to have_content('Martin Prince')
  end
end

Then("there should be a {string} link in the phase banner") do |link_text|
  within('.govuk-phase-banner') do
    expect(page).to have_link(link_text, href: logout_schools_session_path)
  end
end

Given("I am not logged in") do
  # do nothing
end

Then("there should be a {string} link to the DfE services list page") do |link|
  expect(page).to have_link(link, href: Rails.configuration.x.oidc_services_list_url)
end
