Then("I should see a paragraph informing me that some schools require a DBS check") do
  expect(page).to have_css("p.govuk-body-lead", text: "Some schools will carry out these kinds of checks before offering placements")
end

Given("there should be some inset text continaing a link to the DBS website") do
  within('p.govuk-inset-text') do
    expect(page).to have_content 'Find out more'
    expect(page).to have_link 'DBS checks and documents', href: 'https://www.gov.uk/government/organisations/disclosure-and-barring-service/about'
  end
end
