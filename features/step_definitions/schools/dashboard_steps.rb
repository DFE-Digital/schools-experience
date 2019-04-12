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

Given("there are {int} new requests/bookings") do |qty|
  qty
  #  do nothing, currently hard-coded in controller
end

Given("there are {int} new candidate attendances") do |qty|
  qty
  #  do nothing, currently hard-coded in controller
end

Then("the {string} should be {int}") do |string, int|
  expect(page).to have_css("svg#%<id>s" % { id: string.tr(' ', '-') }, text: int.to_s)
end
