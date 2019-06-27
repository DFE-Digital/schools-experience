Given("I have completed the 'preview confirmation email' page") do
  click_button 'Send confirmation email'
end

Then("I should see a panel stating {string}") do |string|
  within('.govuk-panel') do
    expect(page).to have_content(string)
  end
end
