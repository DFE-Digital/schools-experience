Given("there are both {string} and {string} schools in the results") do |phase1, phase2|
  expect(all_education_phases_from_page(page)).to match_array([phase1, phase2])
end

When("I check the {string} filter box") do |string|
  check string
end

When("I click the {string} tag") do |string|
  page.find(".facet-tag__text", text: string).sibling('button').click
end

When("the results have finished loading") do
  expect(page).not_to have_selector(".loading", visible: true)
end

Then("only {string} schools should remain in the results") do |phase|
  expect(all_education_phases_from_page(page)).to match_array([phase])
end

def all_education_phases_from_page(page)
  page
    .all(".govuk-summary-list__row.education-phases > dd.govuk-summary-list__value")
    .map(&:text)
    .uniq
end
