Then("the {string} word count should say {string}") do |label_text, expectation|
  within(page.find("label", text: label_text).ancestor('div.govuk-form-group')) do
    expect(page).to have_css("span.govuk-character-count__message", text: expectation)
  end
end

When("I enter {string} into the {string} text area") do |value, label|
  fill_in label, with: value
end

Then("the {string} section should have {string} and {string} radio buttons") do |section, option_one, option_two|
  within(".#{section.parameterize}") do
    ensure_radio_buttons_exist(page, [option_one, option_two])
  end
end

When("I click the {string} option in the {string} section") do |option, section|
  within(".#{section.parameterize}") do
    expect(choose(option)).to be_checked
  end
end

Given("there is no {string} text area") do |string|
  expect(page).not_to have_field(string, type: 'textarea')
end

Then("a text area labelled {string} should have appeared") do |string|
  expect(page).to have_field(string, type: 'textarea')
end

Given("I have filled in the form with accurate data") do
  fill_in "Is there anything schools need to know about your availability for school experience?", with: "Anytime!"
  fill_in "What do you want to get out of your school experience?", with: "I love teaching"
end
