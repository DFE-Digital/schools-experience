Given("the candidate's name is {string}") do |string|
  # currently hardcoded in the controller
end

Then("the following text should be present:") do |string|
  expect(page).to have_content(string)
end
