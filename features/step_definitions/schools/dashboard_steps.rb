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

Given("my school has not yet fully-onboarded") do
  # do nothing
end

Then("I should see a warning informing me that I need to complete my profile before continuing") do
  within('.govuk-se-warning') do
    expect(page).to have_content('you need to answer some questions to update your school profile')
  end
end

Given("my school has fully-onboarded") do
  FactoryBot.create(:bookings_profile, school: @school)
end

Then("I should see the managing requests section") do
  expect(page).to have_css('.managing-requests')
end
