Then("the {string} word count should say {string}") do |string, string2|
  pending "awaiting patch to form builder enabling counts"
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
  steps %(
    When I fill in the date field "Start date" with 20-02-2022
    And I fill in the date field "End date" with 27-02-2022
  )
  fill_in "What do you want to get out of a placement?", with: "I love teaching"
end
