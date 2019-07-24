Given("the school has created their profile") do
  @profile = FactoryBot.create(:bookings_profile, school: @school)
  expect(@profile).to be_persisted
end

Given("I am on the profile page for the chosen school") do
  path = candidates_school_path(@school.urn)
  visit(path)
  expect(page.current_path).to eql(path)
end

Given("the school profile has description details text:") do |pi|
  @raw_placement_info = pi
  @profile.update_attributes(description_details: pi)
  expect(@profile.description_details).to eql(pi)
end

Then("I should see the correctly-formatted school placement information") do
  within("#school-placement-info") do
    @raw_placement_info.lines.reject(&:blank?).each do |line|
      expect(page).to have_css('p', text: line.strip)
    end
  end
end

Then("the age range should be {string}") do |string|
  within("#school-phases") do
    expect(page).to have_content(string)
  end
end

Given("some subjects exist") do
  @subjects = FactoryBot.create_list(:bookings_subject, 5)
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
  ].compact.each do |address_part|
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
  @profile.update_attributes(
    teacher_training_info: string,
    teacher_training_url: "https://www.altervista.com/teacher-training"
  )
  expect(@profile.teacher_training_info).to eql(string)
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
    expect(page).to have_link("Teacher training: #{@school.name}", href: @profile.teacher_training_url)
  end
end

Then("there should be a button called {string} that begins the wizard") do |string|
  # ensure there's a link
  expect(page).to have_link(string, href: new_candidates_school_registrations_personal_information_path(@school.urn))

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

Given("the chosen school has no availability information") do
  @school.update!(availability_info: nil, availability_preference_fixed: false)
  expect(@school.availability_info).to be_nil
end

Then("the availability information in the sidebar should read {string}") do |string|
  within("#school-availability-info") do
    expect(page).to have_css('dd', text: string)
  end
end

Then("I should see the list of {string} in the sidebar") do |string|
  within('#school-availability-info') do
    expect(page).to have_css('dt', text: string)
    @placement_dates.each do |pd|
      expect(page).to have_css('li', text: pd.to_s)
    end
  end
end

Given("my school of choice has {string} dates") do |option|
  @school = if option == 'fixed'
              FactoryBot.create(:bookings_school, :with_fixed_availability_preference)
            elsif option == 'flexible'
              FactoryBot.create(:bookings_school)
            else
              fail 'invalid flexibility option'
            end
end

Then("there should not be a button called {string} that begins the wizard") do |string|
  expect(page).not_to have_link(string, href: new_candidates_school_registrations_personal_information_path(@school.urn))
end

Given("there are some available dates in the future") do
  [1, 2, 3].each do |i|
    FactoryBot.create(:bookings_placement_date, date: i.weeks.from_now, bookings_school: @school)
  end
end

Then("the DBS Check information in the sidebar should read {string}") do |string|
  within("#dbs-check-info") do
    expect(page).to have_css('dd', text: string)
  end
end

Given("the school charges a {string} fee of {string} for {string}") do |fee_type, amount, description|
  @fee_type = fee_type
  @amount = amount
  @description = description

  @profile.update!(
    "#{fee_type}_fee_amount_pounds" => @amount,
    "#{fee_type}_fee_interval" => 'One-off',
    "#{fee_type}_fee_description" => @description,
    "#{fee_type}_fee_payment_method" => 'Debit card'
  )
end

Then('I should see the fee information') do
  within("##{@fee_type}-fee-info") do
    expect(page).to have_css('p', text: "£#{@amount} One-off, Debit card")
    expect(page).to have_css('p', text: @description)
  end
end

Given("the school does not charge a {string} fee") do |fee_type|
  @fee_type = fee_type
  @profile.update!("#{fee_type}_fee_amount_pounds" => nil)
end

Then("I should not see the fee information") do
  expect(page).not_to have_css("##{@fee_type}")
end

Given("the school has a dress code policy") do
  @profile.update!(
    dress_code_cover_tattoos: true,
    dress_code_smart_casual: true,
    dress_code_other_details: "We were all blue on fridays"
  )
end

Then("I should see the dress code policy information") do
  within("#dress-code") do
    expect(page).to have_css('p', text: 'Cover up tattoos, Smart casual')
    expect(page).to have_css('p', text: 'We were all blue on fridays')
  end
end
