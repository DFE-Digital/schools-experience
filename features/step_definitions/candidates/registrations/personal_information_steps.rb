Then("I should see a paragraph informing me that my details will be used to identify me") do
  within('#main-content') do
    expect(page).to have_content \
      "Provide the following information so we can check if we already have your details."
  end
end
