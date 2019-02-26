Given("that the default results per page is set to {int}") do |int|
  Kaminari.configure do |c|
    c.default_per_page = int
  end
end

Given("there are {int} schools in {string}") do |count, town|
  FactoryBot.create_list(:bookings_school, count, name: town)
  expect(Bookings::School.count).to eql(count)
end

Then("I should see pagination links") do
  expect(page).to have_css('nav.pagination')
end

Then("I should not see pagination links") do
  expect(page).not_to have_css('nav.pagination')
end

Then("pagination page {int} should not be a hyperlink") do |int|
  within('nav.pagination') do
    expect(page).to have_css('span.current', text: '1')
  end
end

Then("pagination page {int} should be a hyperlink") do |int|
  within('nav.pagination') do
    expect(page).to have_css('a', text: '2')
  end
end

When("I navigate to the second page of results") do
  within('.pagination-info.higher > nav.pagination') do
    click_link '2'
  end
end

Then("there should be a {string} link in the pagination") do |string|
  within('nav.pagination') do
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
