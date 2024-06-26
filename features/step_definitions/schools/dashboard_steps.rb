Then("I should see the following {string} links:") do |string, table|
  within('#dashboard') do
    within("##{string}") do
      table.hashes.each do |row|
        expect(page).to have_link(row['Text'], href: row['Path'])

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
  else raise ArgumentError, 'must be true or false'
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
  @bookings = FactoryBot.create_list :bookings_booking, qty, :accepted, bookings_school: @school
  @bookings.each do |b|
    b.date = 1.week.ago
    b.attended = nil
    b.save(validate: false)
  end
end

Given("there is a booking in the past that has been cancelled") do
  @cancelled_booking = FactoryBot.create(:bookings_booking, :accepted, :cancelled_by_school, bookings_school: @school)
end

Then("the {string} should be {int}") do |string, int|
  expect(page).to have_css(sprintf("div#%<id>s", id: string.tr(' ', '-')), text: int.to_s)
end

Given("my school has not yet fully-onboarded") do
  # do nothing
end

Then("I should see a warning informing me that I need to complete my profile before continuing") do
  within('.govuk-notification-banner') do
    expect(page).to have_content('Before you can receive requests, you need to complete your school profile.')
  end
end

Given("my school has fully-onboarded") do
  FactoryBot.create(:bookings_profile, school: @school)
end

Then("I should see the managing requests panel") do
  expect(page).to have_css('#requests')
end

Then("there should be no {string} link") do |link_text|
  expect(page).not_to have_link(link_text)
end

Then("I should see a warning that my school is disabled") do
  expect(page).to have_css('#profile-status', text: 'Your profile is currently off')
end

Then("I shouldn't see any warnings") do
  expect(page).not_to have_css('.govuk-error-summary')
end

Given("my school is part of a group of schools") do
  allow(Rails.application.config.x).to receive(:dfe_sign_in_request_organisation_url) { "https://dfe-sign.in/organisation" }
  allow(SchoolGroup).to receive(:in_group?) { true }
end

Then("there should be a link to the DFE sign in request organisation URL") do
  expect(page).to have_link("Add more schools", href: Rails.application.config.x.dfe_sign_in_request_organisation_url)
end
