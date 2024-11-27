Given("I go to a/the {string} page") do |string|
  visit path_for string
end

Given("I am already on the {string} page") do |string|
  expect(page).to have_current_path(path_for(string))
end

Given("I am on a/the {string} page") do |string|
  step "I go to the '#{string}' page"
  step "I am already on the '#{string}' page"
end

Given("I navigate to the {string} path") do |string|
  step "I am on the '#{string}' page"
end

Given("I am on the {string} page for my school of choice") do |string|
  @school ||= FactoryBot.create(:bookings_school)
  path_for(string, school: @school).tap do |p|
    visit(p)
    expect(page).to have_current_path(p)
  end
end

Given("I save the page") do
  save_page
end

Then("the page's main header/heading should be {string}") do |string|
  expect(page).to have_css("h1", text: string)
end

Then("there should be a section titled {string}") do |string|
  expect(page).to have_css('section > h2.govuk-heading-m', text: string)
end

Then("there should not be a section titled {string}") do |string|
  expect(page).not_to have_css('section > h2.govuk-heading-m', text: string)
end

Then("the page should have a heading called {string}") do |string|
  expect(page).to have_css("h1.govuk-fieldset__heading", text: string)
end

Then("I should see an error message stating {string}") do |string|
  expect(page).to have_css('p.govuk-error-message', text: string)
end

Then("I should see an error") do
  expect(page).to have_css('p.govuk-error-message')
end

Then("I should see a {string} link to the {string}") do |link_text, path|
  expect(page).to have_link(link_text, href: path_for(path))
end

Then("I should see a {string} link to the {string} page") do |link_text, path|
  expect(page).to have_link(link_text, href: path_for(path))
end

Then('I should see a {string} link/button') do |link_text|
  expect(page).to have_link(link_text)
end

Then("I should see a {string} link to the booking") do |link_text|
  expect(page).to have_link(link_text, href: path_for('booking', booking_id: @booking_id))
end

Then("the page title should be {string}") do |title|
  title_suffix = "Get school experience - GOV.UK"
  expect(title).to be_present
  expect(page.title).to eql([title, title_suffix].join(' - '))
end

Then("there should be a {string} warning") do |string|
  within('.govuk-warning-text') do
    expect(page).to have_content(string)
  end
end

Then("there should be a {string} link to the {string}") do |link, target|
  expect(page).to have_link(link, href: path_for(target))
end

Then("I should see the following breadcrumbs:") do |table|
  within('nav.govuk-breadcrumbs') do
    table.hashes.each do |row|
      if row['Link'] == 'None'
        expect(page).to have_css('li', text: row['Text'])
      else
        expect(page).to have_link(row['Text'], href: row['Link'])
      end
    end
  end
end

Then("I should not see any breadcrumbs") do
  expect(page).not_to have_css('nav.govuk-breadcrumbs')
end

Then("I should see a email link to {string}") do |string|
  expect(page).to have_link(string, href: "mailto:#{string}")
end

Then("the main site header should be {string}") do |title_text|
  expect(page).to have_css(
    ".govuk-header .govuk-header__content .govuk-header__service-name",
    text: title_text
  )
end

Then("I should see a notification that {string}") do |string|
  expect(page).to have_content(string)
end

Then("I should see a back link") do
  expect(page).to have_link("Back")
end

Then("I click {string}") do |link|
  click_on link
end
