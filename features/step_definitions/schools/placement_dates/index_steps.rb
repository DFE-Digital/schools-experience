Given("my school has a profile") do
  @school_profile = Schools::SchoolProfile.find_or_create_by!(
    bookings_school: Bookings::School.find_by(urn: 123456)
  )
end

Given("my school has {int} placement dates") do |int|
  @placement_dates = FactoryBot.create_list(:bookings_placement_date, int, school_profile: @school_profile)
  expect(@school_profile.bookings_placement_dates.count).to eql(int)
end

Then("I should see a list with {int} entries") do |int|
  within("#placement-dates") do
    expect(page).to have_css('.placement-date', count: int)
  end
end

Given("my school has a placement date") do
  @placement_date = FactoryBot.create(
    :bookings_placement_date,
    date: 3.weeks.from_now,
    duration: 6,
    school_profile: @school_profile
  )
end

Then("I should my placement date listed") do
  within('#placement-dates .placement-date') do
    expect(page).to have_css('th', text: @placement_date.date.to_formatted_s(:govuk))
    expect(page).to have_css('td', text: "#{@placement_date.duration} days")
  end
end

Then("it should include a {string} link to the edit page") do |string|
  within('#placement-dates .placement-date') do
    expect(page).to have_link(string, href: edit_schools_placement_date_path(@placement_date))
  end
end

Then("there should be a {string} link to the new placement date page") do |string|
  expect(page).to have_link(string, href: new_schools_placement_date_path)
end

Given("my school has no placement dates") do
  expect(@school_profile.bookings_placement_dates).to be_empty
end
