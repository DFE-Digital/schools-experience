Given("I have completed the 'add more details' page") do
  steps %(
    Given I have progressed to the 'add more details' page for my chosen placement request
    And I enter 'Dewey Largo' into the 'Contact name' field
    And I enter '01234 567 890' into the 'Contact number' field
    And I enter 'dlargo@springfield.edu' into the 'Contact email' field
    And I enter 'Some location' into the 'Location' field
    When I submit the form
    Then I should be on the 'review and send email' page for my chosen placement request
  )
end

Then("I should see an email preview with the following subheadings:") do |table|
  within('.email-preview') do
    table.raw.flatten.to_a.each do |heading|
      expect(page).to have_css('h3', text: heading)
    end
  end
end

Then("in the {string} section I should see the following items:") do |section, table|
  within("##{section.parameterize}") do
    table.raw.flatten.to_a.each do |subheading|
      expect(page).to have_content(subheading)
    end
  end
end

Then("the school details section should contain the relevant information") do
  within('section#school-details') do
    [
      @school.name,
      @school.address_1,
      @school.postcode,
      @profile.dress_code,
      @profile.parking_details
    ].each do |item|
      expect(page).to have_content(item)
    end
  end
end

Then("the school experience contacts section should contain the relevant information") do
  within('section#school-experience-contacts') do
    [
      @placement_request.booking.contact_name,
      @placement_request.booking.contact_email,
      @placement_request.booking.contact_number
    ].each do |item|
      expect(page).to have_content(item)
    end
  end
end

Then("the school experience details section should contain the relevant information") do
  within('section#school-experience-details') do
    [
      @placement_request.booking.bookings_subject.name,
      @placement_request.booking.placement_details
    ].each do |item|
      expect(page).to have_content(item)
    end
  end
end

Then("the help and support section should contain the relevant information") do
  within('section#help-and-support') do
    [
      @profile.admin_contact_full_name,
      @profile.admin_contact_email,
      @profile.admin_contact_phone
    ].each do |item|
      expect(page).to have_content(item)
    end
  end
end

Then("the candidate instructions should have been saved") do
  expect(@placement_request.booking.candidate_instructions).to eql(@candidate_instructions)
end
