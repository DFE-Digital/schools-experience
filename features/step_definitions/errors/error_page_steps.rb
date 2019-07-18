Given("I am on the {string} error page") do |http_error|
  code = Rack::Utils::SYMBOL_TO_STATUS_CODE[http_error.to_sym]
  expect(code).to be_an(Integer)

  path = "/#{code}"
  visit(path)
  expect(page.current_path).to eql(path)
end

Then("there should be an email address for support") do
  support_email = "organise.school-experience@education.gov.uk"
  expect(page).to have_link(
    support_email,
    href: "mailto:#{support_email}"
  )
end

Then("there should be some useful hints on entering the correct URL") do
  [
    "If you typed or copied the web address, check it is correct",
    "If you continue to encounter this problem"
  ].each do |snippet|
    expect(page).to have_content(snippet)
  end
end

Then("there should be some useful hints on why I might be here") do
  expect(page).to have_content("Maybe you tried to change something you didn't have access to")
end

Then("there should be some text explaining technical difficulties") do
  expect(page).to have_content("We are currently experiencing technical difficulties")
end

Then("I should see my current school's name") do
  expect(page).to have_css('h1', text: /#{@school.name}/)
end

Then("I should see my name in the body of the page") do
  expect(page).to have_css('p', text: /You are currently logged in as Martin Prince/)
end
