Given("there are some schools with a range of fees containing the word {string}") do |string|
  {
    "Grammar School" => 30,
    "Primary School" => 10,
    "Academy"        => 20
  }
    .map do |school_type, fee|
    FactoryBot.create(
      :bookings_school,
      name: "#{string} #{school_type}",
      fee: fee
    )
  end
end

Given("I have searched for {string} and am on the results page") do |string|
  path = candidates_schools_path(query: string)
  visit(path)
  path_with_query = [page.current_path, URI.parse(page.current_url).query].join("?")
  expect(path_with_query).to eql(path)
end

Given("I have searched for {string} and provided my location") do |string|
  pending "candidate providing location not implemented just yet"
  path = candidates_schools_path(query: string)
  visit(path)
  path_with_query = [page.current_path, URI.parse(page.current_url).query].join("?")
  expect(path_with_query).to eql(path)
end


Given("there are {int} results") do |quantity|
  expect(page).to have_css('ul > li.school-result', count: quantity)
end

Then("each result should have the following information") do |table|
  attributes = table.raw.flatten
  page.all('ul > li.school-result').each do |result|
    attributes.each do |attribute|
      expect(result).to have_css('strong', text: attribute)
    end
  end
end

Then("I should see an {string} filter on the left") do |label|
  within('#search-filter') do
    expect(page).to have_css('legend > span.govuk-label', text: label)
  end
end

Then("it should have the hint text {string}") do |hint|
  within('#search-filter') do
    expect(page).to have_css('legend > span.govuk-hint', text: hint)
  end
end

Then("it should have checkboxes for the following items:") do |table|
  within('#search-filter') do
    table.raw.flatten.each do |option|
      expect(page).to have_field(option, type: 'checkbox')
    end
  end
end

Then("it should have radio buttons for the following items:") do |table|
  within('#search-filter') do
    table.raw.flatten.each do |option|
      expect(page).to have_field(option, type: 'radio')
    end
  end
end

Given("there are some subjects") do
  @subjects = FactoryBot.create_list(:bookings_subject, 3)
end

Then("it should have checkboxes for all subjects") do
  pending "these are currently hardcoded"
  within('#search-filter') do
    @subjects.each do |subject|
      expect(page).to have_field(subject.name, type: 'checkbox')
    end
  end
end

When("I select {string} in the {string} select box") do |option, label_text|
  label = page.find('label', text: label_text)
  select(option, from: label[:for])
end

Then("the results should be sorted by distance, nearest to furthest") do
  pending "sorting not yet implemented"
  # should be ol, results will always be ordered by something?
  # below is pseudocode
  within('ul#results') do
    actual = page.all('li.school-result .name').map(&:text).map(&:name)
    expected = Bookings::School.close_to(@point, radius: 20).reorder('distance asc')
    expect(expected).to eql(actual)
  end
end

Then("the results should be sorted by fee, lowest to highest") do
  pending "sorting not yet implemented"
end
