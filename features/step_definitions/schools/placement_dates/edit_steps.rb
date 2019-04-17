Given("I am on the edit page for my placement") do
  @placement_date = FactoryBot.create(
    :bookings_placement_date,
    date: 3.weeks.from_now,
    duration: 6,
    school_profile: @school_profile
  )
  path = edit_schools_placement_date_path(@placement_date)
  visit path
  expect(page.current_path).to eql(path)
end

Then("my placement should have been deleted") do
  def selector(id)
    "div[data-placement-date-id=#{id}]"
  end

  expect(page).not_to have_css(selector(@placement_date.id))

  #ensure others have been removed and that the selector is functional
  @placement_dates.each do |pd|
    expect(page).to have_css(selector(pd.id))
  end
end
