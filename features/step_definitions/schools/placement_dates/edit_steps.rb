Given("I am on the edit page for my placement") do
  @placement_date = FactoryBot.create(
    :bookings_placement_date,
    date: 3.weeks.from_now,
    duration: 6,
    bookings_school: @school
  )
  path = edit_schools_placement_date_path(@placement_date)
  visit path
  expect(page.current_path).to eql(path)
end

Given("I am on the edit page for my {string} placement") do |state|
  @placement_date = FactoryBot.create(
    :bookings_placement_date,
    state.to_sym,
    date: 3.weeks.from_now,
    duration: 6,
    bookings_school: @school
  )
  path = edit_schools_placement_date_path(@placement_date)
  visit path
  expect(page.current_path).to eql(path)
end

Then("my placement should have been {string}") do |operation|
  description = {
    'deactivated' => 'Closed',
    'activated'   => 'Open'
  }[operation]

  within("tr[data-placement-date-id='#{@placement_date.id}']") do
    expect(page).to have_css('td.status', text: /#{description}/i)
  end
end

Then("the current start date should be present") do
  expect(page).to have_css('.placement-start-date', text: @placement_date.date.strftime('%d %B %Y'))
end
