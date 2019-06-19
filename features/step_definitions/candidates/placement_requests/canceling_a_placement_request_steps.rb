Given "I have made a placement request" do
  @placement_request = FactoryBot.create :placement_request
end

When "I visit the cancellation link" do
  visit \
    path_for "cancel placement request", placement_request: @placement_request
end

Then "I should see a form to enter my cancellation reason" do
  within page.find 'form' do
    expect(page).to have_css 'label', text: 'Cancellation reasons'
    expect(page).to have_field 'reason'
  end
end

Then "I should see the confirmation page for my cancelled {string}" do |string|
  expect(page).to have_css 'h1.govuk-panel__title',
    text: "Your school experience #{string} has been cancelled"
end
