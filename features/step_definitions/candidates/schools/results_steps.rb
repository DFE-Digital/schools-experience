Given("the phases {string} and {string} exist") do |phase_one, phase_two|
  @phase_one = FactoryBot.create(:bookings_phase, name: phase_one)
  @phase_two = FactoryBot.create(:bookings_phase, name: phase_two)
end

Given("there are some schools with a range of fees containing the word {string}") do |string|
  {
    "Grammar School" => {
      phases: [@phase_two],
      fee: 30
    },
    "Primary School" => {
      phases: [@phase_one],
      fee: 10
    },
    "Academy" => {
      phases: [@phase_two],
      fee: 20
    }
  }
    .map do |school_type, attributes|
    FactoryBot.create(
      :bookings_school,
      name: "#{string} #{school_type}",
      phases: attributes[:phases],
      fee: attributes[:fee]
    )
  end
end

Given("I have searched for {string} and am on the results page") do |string|
  path = candidates_schools_path(location: string, distance: 100)
  visit(path)
  path_with_query = [page.current_path, URI.parse(page.current_url).query].join("?")
  expect(path_with_query).to eql(path)
end

Given("there are {int} results") do |quantity|
  expect(page).to have_css('ul > li > .school-result', count: quantity)
end

Then("each result should have the following information") do |table|
  attributes = table.raw.flatten
  page.all('ul > li.school-result').each do |result|
    attributes.each do |attribute|
      expect(result).to have_css('strong', text: attribute)
    end
  end
end

Then("I should see a/an {string} filter on the left") do |label|
  within('#search-filter') do
    expect(page).to have_css('legend', text: label)
  end
end

Then("it should have the hint text {string}") do |hint|
  within('#search-filter') do
    expect(page).to have_css('legend > span.govuk-hint', text: hint)
  end
end

Then("it should have checkboxes for the following items:") do |table|
  within('#search-filter') do
    ensure_check_boxes_exist(page, table.raw.flatten)
  end
end

Then("it should have radio buttons for the following items:") do |table|
  within('#search-filter') do
    ensure_radio_buttons_exist(page, table.raw.flatten)
  end
end

Given("there are some subjects") do
  @subjects = FactoryBot.create_list(:bookings_subject, 3)
end

Then("it should have checkboxes for all subjects") do
  within('#search-filter') do
    form_group = page
      .find('.govuk-label', text: 'Placement subjects')
      .ancestor('div.govuk-form-group')

    ensure_check_boxes_exist(form_group, @subjects.map(&:name))
  end
end

When("I select {string} in the {string} select box") do |option, label_text|
  select(option, from: label_text)
end

Given("I search for schools near {string}") do |string|
  visit(new_candidates_school_search_path)
  fill_in 'Where?', with: string
  click_button 'Find'
  expect(page.current_path).to eql(candidates_schools_path)
end

When("I click back on the results screen") do
  click_link 'Back'
  expect(page.current_path).to eql(new_candidates_school_search_path)
end

Then("the location input should be populated with {string}") do |string|
  expect(page.find('input#location').value).to eql(string)
end

Given("there are no schools near my search location") do
  # do nothing, my location is Bury, Greater Manchester
end

Given("there are some schools just outside it") do
  FactoryBot.create_list(:bookings_school, 2, coordinates: Bookings::School::GEOFACTORY.point(-2.421, 53.624))
end

When("I search for schools within {int} miles") do |int|
  path = candidates_schools_path(location: 'Bury', distance: int)
  visit(path)
  path_with_query = [page.current_path, URI.parse(page.current_url).query].join("?")
  expect(path_with_query).to eql(path)
end

Then("the results page should include a warning that my search radius was expanded") do
  within('#results li.expanded-search-radius') do
    expect(page).to have_css('h3', text: '0 results found within 5 miles')
    expect(page).to have_content('However, we did find the following schools nearby:')
  end
end

Then("the results from further out are displayed") do
  expect(page).to have_css('article.school-result', count: Bookings::School.count)
end

Given("there are no schools in or around my search location") do
  # do nothing
end

Then("the results page should include a warning that no results were found") do
  within('#results li.expanded-search-radius') do
    expect(page).to have_css('h3', text: '0 results found within 5 miles')
    expect(page).to have_content("There aren't any results within 50 miles of your location")
  end
end
