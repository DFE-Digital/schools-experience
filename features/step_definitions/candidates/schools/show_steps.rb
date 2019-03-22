Given("there is a school called {string}") do |name|
  @school = FactoryBot.create(:bookings_school, :full_address, name: name)
  expect(@school).to be_persisted
end

Given("I am on the profile page for the chosen school") do
  path = candidates_school_path(@school.urn)
  visit(path)
  expect(page.current_path).to eql(path)
end

Given("the school has placement information text:") do |pi|
  @raw_placement_info = pi
  @school.update_attributes(placement_info: pi)
  expect(@school.placement_info).to eql(pi)
end

Then("I should see the correctly-formatted school placement information") do
  within("#school-placement-info") do
    @raw_placement_info.lines.reject(&:blank?).each do |line|
      expect(page).to have_css('p', text: line.strip)
    end
  end
end

Given("the school has is a {string} school") do |phase_name|
  @school.phases << Bookings::Phase.find_by(name: phase_name)
end

Then("the age range should be {string}") do |string|
  within("#school-phases") do
    expect(page).to have_content(string)
  end
end

Given("the school is a {string} and {string} school") do |p1, p2|
  [p1, p2].each do |phase_name|
    @school.phases << Bookings::Phase.find_by(name: phase_name)
  end
end

Given("some subjects exist") do
  @subjects = FactoryBot.create_list(:bookings_subject, 5)
end

Given("the school offers {int} subjects") do |int|
  @school.subjects << @subjects.first(int)
  expect(@school.subjects.size).to eql(int)
end

Then("all of the subjects should be listed") do
  within("#school-subjects") do
    @school.subjects.each do |subject|
      expect(page).to have_content(subject.name)
    end
  end
end

Given("the school's website is {string}") do |url|
  @school.update_attributes(website: url)
  expect(@school.website).to eql(url)
end

Then("I should see a hyperlink to the school's website") do
  within('#school-website') do
    expect(page).to have_link("#{@school.name} website", href: @school.website)
  end
end

Given("my chosen school has the URN {int}") do |int|
  @school.update_attributes(urn: int)
  expect(@school.urn).to eql(int)
end

Then("I should see the following websites listed:") do |table|
  within('#school-websites') do
    table.hashes.each do |row|
      expect(page).to have_link(row['description'], href: row['url'])
    end
  end
end

Then("I should see the entire school address in the sidebar") do
  [
    @school.address_1,
    @school.address_2,
    @school.address_3,
    @school.town,
    @school.county,
    @school.postcode
  ].each do |address_part|
    within(".govuk-grid-column-one-third") do
      within("#school-address") do
        expect(page).to have_content(address_part)
      end
    end
  end
end

Given("the chosen school has the following availability information") do |string|
  @raw_availability_info = string
  @school.update_attributes(availability_info: string)
  expect(@school.availability_info).to eql(string)
end

Then("I should see availability information in the sidebar") do
  within("#school-availability-info") do
    @raw_availability_info.lines.reject(&:blank?).each do |line|
      expect(page).to have_css('p', text: line.strip)
    end
  end
end

Given("the chosen school offers teacher training and has the following info") do |string|
  @teacher_training_info = string
  @school.update_attributes(
    teacher_training_provider: true,
    teacher_training_info: string,
    teacher_training_website: "https://www.altervista.com/teacher-training"
  )
  expect(@school.teacher_training_info).to eql(string)
end

Then("I should see teacher training information information in the sidebar") do
  within("#school-teacher-training-info") do
    @teacher_training_info.lines.reject(&:blank?).each do |line|
      expect(page).to have_css('p', text: line.strip)
    end
  end
end

Then("the teacher training website should be listed with the other hyperlinks") do
  within("#school-websites") do
    expect(page).to have_link("Teacher training: #{@school.name}", href: @school.teacher_training_website)
  end
end

Then("there should be a button called {string} that begins the wizard") do |string|
  # ensure there's a link
  expect(page).to have_link(string, href: new_candidates_school_registrations_placement_preference_path(@school.urn))

  # and make sure it's button-like
  expect(page).to have_css(".govuk-button", text: string)
end

Given("my chosen school has no subjects") do
  expect(@school.subjects).to be_empty
end

Then("the subjects section should not be displayed") do
  expect(page).not_to have_css("#school-subjects")
end

Given("my chosen school has no placement information") do
  expect(@school.placement_info).to be_blank
end

Then("the placement information section should not be visible") do
  expect(page).not_to have_css("#school-placement-info")
end
