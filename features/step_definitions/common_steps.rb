Given("I am on the {string} page") do |string|
  path_for(string).tap do |p|
    visit(p)
    expect(page.current_path).to eql(p)
  end
end

Given("I am on the {string} page for my school of choice") do |string|
  @school = FactoryBot.create(:bookings_school)
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
