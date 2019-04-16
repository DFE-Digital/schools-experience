Given("there are some bookings") do
  # currently hardcoded in the controller
end

Given("there is at least one booking") do
  # currently hardcoded in the controller
end

Then("I should see all the bookings listed") do
  within("#bookings") do
    expect(page).to have_css('.booking', count: 5)
  end
end

Then("the bookings should have the following values:") do |table|
  within('#bookings') do
    within(page.all('.booking').first) do
      table.hashes.each do |row|
        expect(page).to have_css('dt', text: row['Heading'])
        expect(page).to have_css('dd', text: /#{row['Value']}/i)
      end
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
        expect(page).to have_link('Open booking', href: schools_booking_path('abc123'))
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
