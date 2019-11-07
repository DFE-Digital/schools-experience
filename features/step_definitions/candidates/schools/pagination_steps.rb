Given("there are {int} {string} schools in {string}") do |count, age_group, town|
  FactoryBot.create_list(:bookings_school, count, age_group.downcase.to_sym, name: town)
  expect(Bookings::School.count).to eql(count)
end

Then("I should see pagination links") do
  expect(page).to have_css('nav.pagination')
end

Then("I should not see pagination links") do
  expect(page).not_to have_css('nav.pagination')
end

Then("pagination page {int} should not be a hyperlink") do |int|
  within('.pagination-info.higher > nav.pagination') do
    expect(page).to have_css('span.current', text: int)
  end
end

Then("pagination page {int} should be a hyperlink") do |int|
  within('.pagination-info.higher > nav.pagination') do
    expect(page).to have_css('a', text: int)
  end
end

When("I navigate to the second page of results") do
  within('.pagination-info.higher > nav.pagination') do
    click_link '2'
  end
end

Then("there should be a {string} link in the pagination") do |string|
  within('.pagination-info.higher > nav.pagination') do
    expect(page).to have_css('a', text: string)
  end
end

Then("there should be {int} set/sets of pagination links") do |int|
  expect(page).to have_css('nav.pagination', count: int)
end

Then("the pagination description should say {string}") do |string|
  within('.pagination-slice') do
    expect(page).to have_content(string)
  end
end
