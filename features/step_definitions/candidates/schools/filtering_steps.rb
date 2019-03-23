Given("there are both {string} and {string} schools in the results") do |phase1, phase2|
  expect(all_education_phases_from_page(page)).to match_array([phase1, phase2])
end

When("I check the {string} filter box") do |string|
  check string
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
