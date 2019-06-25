Then("I should see the following {string} links:") do |string, table|
  within('#dashboard') do
    table.hashes.each do |row|
      link = page.find_link(row['Text'], href: row['Path'])
      container = link.ancestor('section')

      within(container) do
        expect(page).to have_css(".dashboard-#{string}")

        if (hint = row['Hint']) && hint != 'None'
          expect(page).to have_css('p.govuk-hint', text: hint)
        end
      end
    end
  end
end

Then("I should see the dashboard") do
  expect(page).to have_css('h1', text: "Manage school experience at #{@school.name}")
end

Given("there are {int} new requests") do |qty|
  FactoryBot.create_list :placement_request, qty, school: @school
end

Given("there are {int} new bookings") do |qty|
  FactoryBot.create_list :bookings_booking, qty, :upcoming, bookings_school: @school
end


Given("there are {int} new candidate attendances") do |qty|
  qty
  #  do nothing, currently hard-coded in controller
end

Then("the {string} should be {int}") do |string, int|
  expect(page).to have_css("svg#%<id>s" % { id: string.tr(' ', '-') }, text: int.to_s)
end
