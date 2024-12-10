Given("I am on the edit page for my {string} placement") do |type|
  @placement_date = FactoryBot.create(
    :bookings_placement_date,
    date: 3.weeks.from_now,
    duration: 6,
    bookings_school: @school,
    recurring: type == "recurring"
  )
  path = edit_schools_placement_date_path(@placement_date)
  visit path
  expect(page).to have_current_path(new_schools_placement_date_placement_detail_path(@placement_date))
end

Given("I am on the edit page for my placement that is {string}") do |state|
  @placement_date = FactoryBot.create(
    :bookings_placement_date,
    state.to_sym,
    date: 3.weeks.from_now,
    duration: 6,
    bookings_school: @school
  )
  path = new_schools_placement_date_placement_detail_path(@placement_date)
  visit path
  expect(page).to have_current_path(path)
end

When("I click the 'Close placement date' link") do
  page.find("a", text: "Close placement date").click
end

Then("my placement should have been {string}") do |operation|
  description = {
    'deactivated' => 'Closed',
    'activated' => 'Open'
  }[operation]

  within("tr[data-placement-date-id='#{@placement_date.id}']") do
    expect(page).to have_css('td.status', text: /#{description}/i)
  end
end
