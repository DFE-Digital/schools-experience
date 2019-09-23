Then("I should see the following {string} links:") do |string, table|
  within('#dashboard') do
    table.hashes.each do |row|
      link = page.find_link(row['Text'], href: row['Path'])
      container = link.ancestor('section')

      within(container) do
        expect(page).to have_css(".dashboard-#{string}")

        if (hint = row['Hint']) && hint != 'None'
          expect(page).to have_css('.govuk-hint', text: Regexp.new(hint))
        end
      end
    end
  end
end

When 'it has {string} availability' do |availability_option|
  case availability_option
  when 'fixed' then @school.update(availability_preference_fixed: true)
  when 'flexible' then @school.update(availability_preference_fixed: false)
  else fail ArgumentError, 'must be true or false'
  end
end

Then("I should see the dashboard") do
  expect(page).to have_css('h1', text: "Manage school experience at #{@school.name}")
end

Given("there are {int} new requests") do |qty|
  FactoryBot.create_list :placement_request, qty, school: @school
end

Given("there are {int} new bookings") do |qty|
  FactoryBot.create_list :bookings_booking, qty, :upcoming, :accepted, bookings_school: @school
end

Given("there are {int} unviewed candidate cancellations") do |qty|
  FactoryBot.create_list \
    :bookings_booking, qty, :cancelled_by_candidate, bookings_school: @school
end

Given("there are {int} bookings in the past with no attendance logged") do |qty|
  @bookings = FactoryBot.create_list :bookings_booking, qty, bookings_school: @school
  @bookings.each do |b|
    b.date = 1.week.ago
    b.attended = nil
    b.save(validate: false)
  end
end

Then("the {string} should be {int}") do |string, int|
  expect(page).to have_css("div#%<id>s" % { id: string.tr(' ', '-') }, text: int.to_s)
end

Given("my school has not yet fully-onboarded") do
  # do nothing
end

Then("I should see a warning informing me that I need to complete my profile before continuing") do
  within('.govuk-error-summary') do
    expect(page).to have_content('you need to answer some questions to update your school profile')
  end
end

Given("my school has fully-onboarded") do
  FactoryBot.create(:bookings_profile, school: @school)
end

Then("I should see the managing requests section") do
  expect(page).to have_css('.managing-requests')
end

Then("there should be no {string} link") do |link_text|
  expect(page).not_to have_link(link_text)
end
