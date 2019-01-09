Given("I visit the landing page") do
  visit "/pages/home"
end

Then("I should see text {string}") do |string|
  expect(page).to have_text(string)
end
