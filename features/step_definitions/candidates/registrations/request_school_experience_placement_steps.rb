Then("the {string} word count should say {string}") do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

When("I enter {string} into the {string} text area") do |value, label|
  fill_in label, with: value
end

Then("the {string} section should have {string} and {string} radio buttons") do |section, option_one, option_two|
  within(".#{section.parameterize}") do
    [option_one, option_two].each do |opt|
      expect(page).to have_field(opt, type: 'radio')
    end
  end
end

When("I click the {string} option in the {string} section") do |option, section|
  within(".#{section.parameterize}") do
    expect(choose(option)).to be_checked
  end
end

Then("a text area labelled {string} should appear") do |string|
  pending "awaiting @javascript driver config"
end

Given("I have filled in the form with accurate data") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I submit the form") do
  pending # Write code here that turns the phrase above into concrete actions
end
