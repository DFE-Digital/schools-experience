Given("my school of choice has entered some placement dates") do
  FactoryBot.create_list(:bookings_placement_date, 3, bookings_school: @school)
end

Then("the start button should link to the {string} page") do |page_name|
  expect(page).to have_link('Start request', href: path_for(page_name, school: @school))
end
