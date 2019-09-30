Given("the scheduled booking date is {string}") do |string|
  @scheduled_booking_date = string
end

Given("there are some bookings") do
  step "there are 3 bookings"
end

Given("there is at least one booking") do
  step "there is 1 booking"
end

Given("there is a cancelled booking") do
  unless @school.subjects.where(name: 'Biology').any?
    @school.subjects << FactoryBot.create(:bookings_subject, name: 'Biology')
  end
  @booking = FactoryBot.create :bookings_booking,
    :cancelled_by_candidate,
    bookings_school: @school,
    bookings_subject: @school.subjects.last,
    date: 1.week.from_now.strftime("%d %B %Y")

  @booking_id = @booking.id
end

Given("I am viewing my chosen booking") do
  path = path_for('booking', booking_id: @booking_id)
  visit(path)
  expect(page.current_path).to eql(path)
end

And("there is/are {int} booking/bookings") do |count|
  @scheduled_booking_date ||= 1.week.from_now.strftime("%d %B %Y")
  unless @school.subjects.where(name: 'Biology').any?
    @school.subjects << FactoryBot.create(:bookings_subject, name: 'Biology')
  end
  @bookings = FactoryBot.create_list(
    :bookings_booking,
    count,
    :with_existing_subject,
    :accepted,
    bookings_school: @school,
    date: @scheduled_booking_date
  )
  @booking = @bookings.first
  @booking_id = @booking.id
end

Given("there are some bookings belonging to other schools") do
  @other_school_bookings = FactoryBot.create_list(:bookings_booking, 2, date: 1.week.from_now)
  @other_school_bookings.each do |b|
    expect(b.bookings_school).not_to eql(@school)
  end
end

Then("I should only see bookings belonging to my school") do
  within('table#bookings tbody') do
    @bookings.map(&:id).each do |booking_id|
      expect(page).to have_css(".booking[data-booking='#{booking_id}']")
    end
    @other_school_bookings.map(&:id).each do |booking_id|
      expect(page).not_to have_css(".booking[data-booking='#{booking_id}']")
    end
  end
end

Then("I should see all the bookings listed") do
  within("#bookings") do
    expect(page).to have_css('.booking', count: 3)
  end
end

Then("the bookings table should have the following values:") do |table|
  within('table#bookings') do
    table.hashes.each do |row|
      within(page.find('thead > tr')) do
        expect(page).to have_css('th', text: row['Heading'])
      end

      within(page.find('tbody').all('tr').first) do
        expect(page).to have_css('td', text: /#{row['Value']}/i)
      end
    end
  end
end

Then("the booking date should be correct") do
  within('table#bookings') do
    within(page.find('tbody').all('tr').first) do
      expect(page).to have_css('td', text: @scheduled_booking_date)
    end
  end
end

When("I click {string} on the first booking") do |string|
  within('#bookings') do
    within(page.all('.booking').first) do
      page.find('summary span', text: string).click
    end
  end
end

Then("every booking should contain a link to view more details") do
  within('#bookings') do
    page.all('.booking').each do |sr|
      within(sr) do
        booking_id = sr['data-booking']
        expect(page).to have_link('View', href: schools_booking_path(booking_id))
      end
    end
  end
end

Then("every booking should contain a title starting with {string}") do |string|
  within('#bookings') do
    page.all('.booking').each do |sr|
      within(sr) do
        expect(page).to have_css('h2', text: /#{string}/)
      end
    end
  end
end

Then("I should see the following contact details for the first booking:") do |table|
  within(page.all('.booking').first) do
    within('.contact-details dl') do
      table.hashes.each do |row|
        expect(page).to have_css('dt', text: row['Heading'])
        expect(page).to have_css('dd', text: /#{row['Value']}/i)
      end
    end
  end
end

Given("there are some non-upcoming bookings") do
  @non_upcoming_bookings = FactoryBot.create_list(:bookings_booking, 3, date: 1.month.from_now)
end

Then("the upcoming bookings should be listed") do
  within('table#bookings tbody') do
    @bookings.map(&:id).each do |booking_id|
      expect(page).to have_css(".booking[data-booking='#{booking_id}']")
    end
  end
end

Then("the non-upcoming bookings shouldn't") do
  within('table#bookings tbody') do
    @non_upcoming_bookings.map(&:id).each do |booking_id|
      expect(page).not_to have_css(".booking[data-booking='#{booking_id}']")
    end
  end
end

Given("there are no bookings") do
  # do nothing
end

Then("I should see the text {string}") do |string|
  expect(page).to have_text string
end

Then("I should not see the bookings table") do
  expect(page).not_to have_css('table#bookings')
end

Then("the page title should start with {string} and include the booking reference") do |string|
  expect(page.title).to start_with(string)
  expect(page.title).to include(@booking.reference)
end

Then("I should not see a {string} section") do |string|
  expect(page).not_to have_css "section##{string.downcase.tr(' ', '-')}"
end
