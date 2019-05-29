Given("the candidate's name is {string}") do |string|
  # currently hardcoded in the controller
end

Given("I am on the reject placement request page") do
  path = path_for("reject placement request", placement_request_id: @placement_request.id)
  visit(path)
  expect(page.current_path).to eql(path)
end

Then("the following text should be present:") do |string|
  expect(page).to have_content(string)
end
