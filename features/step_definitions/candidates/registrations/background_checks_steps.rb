Then("I should see a paragraph informing me that some schools require a DBS check") do
  expect(page).to have_css("p", text: "Some schools may ask you to have a criminal record check through the Disclosure and Barring Service (DBS) before offering you school experience.")
end

Given("there should be some text continaing a link to the DBS website") do
  expect(page).to have_link "Find out more about 'DBS checks' and 'DBS certificates'", href: 'https://www.gov.uk/government/organisations/disclosure-and-barring-service/about'
end
