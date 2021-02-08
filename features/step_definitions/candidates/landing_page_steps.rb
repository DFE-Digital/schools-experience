Then("the leading paragraph should provide me with a summary of the service") do
  within('.govuk-main-wrapper div > p:first-of-type') do
    [
      'Use this service',
      'request school experience in a primary or secondary school',
      'England'
    ].each do |snippet|
      expect(page).to have_text(snippet)
    end
  end
end

Then("the page should include a paragraph on DBS checks with a link to the service") do
  within('p', text: /undergo a Disclosure and Barring/) do
    expect(page).to have_link(
      'Disclosure and Barring Service (DBS) check',
      href: 'https://www.gov.uk/government/organisations/disclosure-and-barring-service/about'
    )
  end
end

Then("I should see a warning informing me that school experiences are only available in England") do
  within('p.govuk-inset-text.warning-location-phase') do
    expect(page).to have_text('This service is only available for school experience at primary and secondary schools in England.')
  end
end

When("I click the {string} button") do |string|
  click_link(string)
rescue Capybara::ElementNotFound
  click_button(string)
ensure
  delay_page_load
end

Then("I should be on the {string} page") do |string|
  expect(path_for(string)).to eql(page.current_path)
end

Then("I should be on the {string} page for my school of choice") do |string|
  expect(page.current_path).to eql(path_for(string, school: @school))
end

Then("I should see a column on the right with the following useful links:") do |table|
  within('aside nav') do
    table.raw.to_h.each do |link, href|
      expect(page).to have_link(link, href: href)
    end
  end
end

Then("the right column should have the subheading {string}") do |string|
  within('aside') do
    expect(page).to have_css('h2.govuk-heading-m', text: string)
  end
end

Then("it should contain some useful information about the process") do
  within('.before-you-start') do
    [
      "During school holidays",
      "Some schools charge fees",
      "receive tailored advice about becoming a teacher",
    ].each do |snippet|
      expect(page).to have_content(snippet)
    end
  end
end

Then("there should be no {string} link in the phase banner") do |link|
  within('.govuk-phase-banner') do
    expect(page).not_to have_link(link)
  end
end
