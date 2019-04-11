Then("I should see the following booking details:") do |table|
  table.hashes.each do |row|
    within('#booking-details') do
      expect(page).to have_css('dt', text: row['Heading'])
      expect(page).to have_css('dd', text: row['Value'])
    end
  end
end

Then("every row of the booking details list should have a {string} link") do |string|
  within('#booking-details') do
    page.all('div.govuk-summary-list__row').each do |row|
      expect(row).to have_link('Change')
    end
  end
end
