Given("there are some cancelled bookings") do
  step "there are 3 cancelled bookings"
end

Given("there is at least one cancelled booking") do
  step "there is 1 cancelled booking"
end

Then("I should see the cancelled bookings listed") do
  within("#bookings") do
    expect(page).to have_css('.booking', count: 3)
  end
end

And("there is/are {int} cancelled booking/bookings") do |count|
  biology_subject = @school.subjects.find_by(name: 'Biology')

  @bookings = (1..count).map do |_index|
    FactoryBot.create(
      :bookings_booking,
      :cancelled_by_school,
      bookings_school: @school,
      bookings_subject: biology_subject
    )
  end

  @booking = @bookings.first
  @booking_id = @booking.id
end

Given("there are some cancelled bookings belonging to other schools") do
  @other_school_bookings = FactoryBot.create_list(:bookings_booking, 2, :cancelled_by_school)
  @other_school_bookings.each do |b|
    expect(b.bookings_school).not_to eql(@school)
  end
end

When("I am viewing my chosen cancelled booking") do
  path = path_for('cancelled booking', booking_id: @booking_id)
  visit(path)
  expect page.to have_current_path(path)
end

Given("there is a cancelled booking") do
  @booking = FactoryBot.create :bookings_booking,
    :cancelled_by_candidate, :accepted,
    bookings_school: @school,
    bookings_subject: @school.subjects.last

  @booking_id = @booking.id
end

Then("every booking should contain a link to view cancelled booking details") do
  within('#bookings') do
    page.all('.booking').each do |sr|
      within(sr) do
        booking_id = sr['data-booking']
        expect(page).to have_link('View', href: schools_cancelled_booking_path(booking_id))
      end
    end
  end
end

Then("I should see a {string} section") do |string|
  expect(page).to have_css "section##{string.downcase.tr(' ', '-')}"
end
