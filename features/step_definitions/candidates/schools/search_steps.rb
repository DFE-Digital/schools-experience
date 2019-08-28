Then("I should see the school search form") do
  within('#search-form') do
    @form = page.find('form')
  end
end

Then("it should have a blank search field") do
  within(@form) do
    field = page.find_field('Enter location or postcode', type: 'search')
    expect(field['required']).to be_present
    expect(field.text).to be_blank
  end
end

Then("there should be a {string} select box with the following options:") do |string, table|
  within(@form) do
    within(page.find_field(string)) do
      table.raw.to_h.each do |value, distance|
        expect(page).to have_css("option[value='#{value}']", text: distance)
      end
    end
  end
end

Then("the submit button should be labelled {string}") do |string|
  within(@form) do
    expect(page).to have_button(string)
  end
end

Given("I have made an invalid search for schools near {string}") do |string|
  path = candidates_schools_path
  visit(candidates_schools_path(location: string))
  expect(page.current_path).to eql(path)
end
