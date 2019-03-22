Then("I should see a paragraph informing me that my details will be used by schools to contact me") do
  within('#main-content') do
    expect(page).to have_content \
      "Your details will be used by schools to contact you about school experience once you’ve sent them a request."
  end
end
