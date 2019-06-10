Given("the subjects {string} and {string} exist") do |subj1, subj2|
  [subj1, subj2].each { |s| FactoryBot.create(:bookings_subject, name: s) }
end

Given("there are some upcoming requests") do
end

Given("there are some placement requests") do
  @placement_requests = FactoryBot.create_list(:bookings_placement_request, 3, school: @school)
end

Given("there is at least one placement request") do
  @placement_request = FactoryBot.create(:bookings_placement_request, school: @school)
end

Given("I am on the placement request page") do
  path = path_for('placement request', placement_request: @placement_request)
  visit(path)
  expect(page.current_path).to eql(path)
end

Then("I should see all the upcoming requests listed") do
  within("#placement-requests") do
    expect(page).to have_css('.placement-request', count: @placement_requests.size)
  end
end

Then("I should see all the placement requests listed") do
  within("#placement-requests") do
    expect(page).to have_css('.placement-request', count: @placement_requests.size)
  end
end

Then("the placement listings should have the following values:") do |table|
  within('#placement-requests') do
    within(page.all('.placement-request').first) do
      table.hashes.each do |row|
        expect(page).to have_css('dt', text: row['Heading'])
        expect(page).to have_css('dd', text: /#{row['Value']}/i)
      end
    end
  end
end

Then("every request should contain a link to view more details") do
  within('#placement-requests') do
    @placement_requests.each do |placement_request|
      within("div.placement-request[data-placement-request='#{placement_request.id}']") do
        expect(page).to have_link('Open request', href: schools_placement_request_path(placement_request.id))
      end
    end
  end
end

Then("every request should contain a title starting with {string}") do |string|
  within('#placement-requests') do
    page.all('.placement-request').each do |sr|
      within(sr) do
        expect(page).to have_css('h2', text: /#{string}/)
      end
    end
  end
end

Then("I should see a {string} section with the following values:") do |heading, table|
  within("section##{heading.parameterize}") do
    expect(page).to have_css('h2', text: heading)
    table.hashes.each do |row|
      expect(page).to have_css('dt', text: row['Heading'])

      if row['Heading'].match?(/subjects/)
        row['Value'].split(", ").each do |subject|
          expect(page).to have_css('dd', text: /#{subject}/i)
        end
      else
        expect(page).to have_css('dd', text: /#{row['Value']}/i)
      end
    end
  end
end

Then("there should be the following buttons:") do |table|
  # note that button_to inserts a form with a submit input so
  # if we don't find a regular link/button check for that too
  table.transpose.raw.flatten.each do |button_text|
    within('.accept-or-reject') do
      begin
        expect(page).to have_css('.govuk-button', text: button_text)
      rescue RSpec::Expectations::ExpectationNotMetError
        expect(page).to have_css("input.govuk-button[value='#{button_text}']")
      end
    end
  end
end

When("I click {string} on the first request") do |string|
  within('#placement-requests') do
    within(page.all('.placement-request').first) do
      page.find('summary span', text: string).click
    end
  end
end

Then("I should see the following contact details:") do |table|
  within(page.all('.placement-request').first) do
    within('.contact-details dl') do
      table.hashes.each do |row|
        expect(page).to have_css('dt', text: row['Heading'])
        expect(page).to have_css('dd', text: /#{row['Value']}/i)
      end
    end
  end
end

Then("I should be on the confirm booking page") do
  path = path_for('confirm booking', placement_request: @placement_request)
  visit(path)
  expect(page.current_path).to eql(path)
end
