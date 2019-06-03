Given("the candidate's name is {string}") do |string|
  # currently hardcoded in the controller
end

When "I am on the reject placement request page" do
  visit \
    path_for 'reject placement request', placement_request: @placement_request
end

Then("the following text should be present:") do |string|
  expect(page).to have_content(string)
end
