Given("I am on a/the {string} page") do |string|
  path_for(string).tap do |p|
    visit(p)
    expect(page.current_path).to eql(p)
  end
end

Given("I am already on the {string} page") do |string|
  expect(page.current_path).to eql(path_for(string))
end

Given("I navigate to the {string} path") do |string|
  step "I am on the '#{string}' page"
end

Given("I am on the {string} page for my school of choice") do |string|
  @school ||= FactoryBot.create(:bookings_school)
  path_for(string, school: @school).tap do |p|
    visit(p)
    expect(page.current_path).to eql(p)
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

Then("the page should have a heading called {string}") do |string|
  expect(page).to have_css("h1.govuk-fieldset__heading", text: string)
end

Then("I should see an error message stating {string}") do |string|
  expect(page).to have_css('span.govuk-error-message', text: string)
end

Then("I should see a {string} link to the {string}") do |link_text, path|
  expect(page).to have_link(link_text, href: path_for(path))
end

Then("I should see a {string} link to the {string} page") do |link_text, path|
  expect(page).to have_link(link_text, href: path_for(path))
end

Then("the page title should be {string}") do |title|
  title_suffix = "DfE School Experience"
  expect(title).to be_present
  expect(page.title).to eql([title, title_suffix].join(' | '))
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

Then("I should see a email link to {string}") do |string|
  expect(page).to have_link(string, href: "mailto:#{string}")
end
