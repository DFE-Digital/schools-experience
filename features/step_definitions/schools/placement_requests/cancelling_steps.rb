When "I am on the reject placement request page" do
  visit \
    path_for 'reject placement request', placement_request: @placement_request
end

Then("the following text should be present:") do |string|
  expect(page).to have_content(string)
end

Given("I have entered a reason in the cancellation reasons text area") do
  fill_in 'reason', with: 'The school is full'
end

Given("I have entered a extra details in the extra details text area") do
  fill_in 'Extra details', with: "It's a popular school"
end

Then("I should see a preview of what I have entered") do
  within '#rejection-details' do
    expect(page).to have_content 'The school is full'
  end

  within '#extra-details' do
    expect(page).to have_content "It's a popular school"
  end
end
