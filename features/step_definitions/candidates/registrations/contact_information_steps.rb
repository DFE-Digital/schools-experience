Then("I should see a paragraph informing me that my details will be used by schools to contact me") do
  within('#main-content') do
    expect(page).to have_content \
      "Schools will use these details to contact you about school experience once you've sent them a request."
    expect(page).to have_content \
      "If a school accepts your request, the school experience service will send you text message alerts about your booking."
  end
end
