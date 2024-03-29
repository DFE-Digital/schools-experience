Given "I check {string}" do |string|
  check string
end

Given("the Task Based On-boarding feature is enabled") do
  allow(Feature).to receive(:enabled?).with(:task_progress_on_boarding)
    .and_return(true)
end

Given("I am on-boarding a new school") do
  new_school = FactoryBot.create(:bookings_school, name: "New School", urn: 123_490)

  allow_any_instance_of(Schools::DFESignInAPI::Organisations).to \
    receive(:uuids).and_return \
      SecureRandom.uuid => new_school.urn
end

Given("I am on-boarding a new school and have access to another school that is already on-boarded") do
  existing_school = FactoryBot.create(:bookings_school, :onboarded, :with_school_profile, name: "Existing School", urn: 123_489)
  new_school = FactoryBot.create(:bookings_school, name: "New School", urn: 123_490)

  allow_any_instance_of(Schools::DFESignInAPI::Organisations).to \
    receive(:uuids).and_return \
      SecureRandom.uuid => existing_school.urn,
      SecureRandom.uuid => new_school.urn

  allow(Schools::PrepopulateSchoolProfile).to \
    receive(:enabled?).and_return(true)
end

Given "I have completed the DBS Requirements step" do
  steps %(
    Given I am on the 'DBS requirements' page
    And I choose 'Yes, for in-school and virtual experience' from the 'Do candidates need to have or get a DBS check?' radio buttons
    And I enter 'Always require DBS check' into the 'Provide details in 50 words or less.' text area
    When I submit the form
  )
end

Given "I have completed the DBS Requirements step, choosing No" do
  steps %(
    Given I am on the 'DBS requirements' page
    And I choose 'No, candidates will be accompanied at all times' from the 'Do candidates need to have or get a DBS check?' radio buttons
    When I submit the form
  )
end

Given "I have completed the Candidate Requirements selection step" do
  steps %(
    Given I am on the 'candidate requirements selection' page
    And I check "Candidates must apply to our (or a partner school's) teacher training course"
    And I check "Candidates must live locally"
    And I enter '7' into the 'Tell us within how many miles of your school. For example, 20.' text area
    And I check 'Other'
    And I enter 'Some details' into the 'Provide details.' text area
    When I submit the form
  )
end

Given "I have completed the Fees step, choosing only Administration costs" do
  steps %(
    Given I am on the 'fees charged' page
    And I check 'Administration costs'
    When I submit the form
  )
end

Given "I have completed the Fees step, choosing only DBS costs" do
  steps %(
    Given I am on the 'fees charged' page
    And I check 'DBS check costs'
    When I submit the form
  )
end

Given "I have completed the Fees step, choosing only Other costs" do
  steps %(
    Given I am on the 'fees charged' page
    And I check 'Other costs'
    When I submit the form
  )
end

Given "I have completed the Other costs step" do
  steps %(
    Given I have entered the following details into the form:
      | Enter the number of pounds   | 300              |
      | Explain what the fee covers. | Falconry lessons |
      | Explain how the fee is paid  | Gold sovereigns  |
    And I choose 'Daily' from the 'Is this a daily or one-off fee?' radio buttons
    When I submit the form
  )
end

Given "I have completed the Phases step" do
  steps %(
    Given I am on the 'phases' page
    And I check 'Secondary (11 to 16 years)'
    And I check '16 to 18 years'
    When I submit the form
  )
end

Given "I have completed the Subjects step" do
  steps %(
    Given I am on the 'Subjects' page
    And I check 'Maths'
    When I submit the form
  )
end

Given "I have completed the College subjects step" do
  steps %(
    Given I am on the 'College subjects' page
    And I check 'Maths'
    When I submit the form
  )
end

Given "I have completed the Description step" do
  steps %(
    Given I am on the 'Description' page
    And I enter 'We have a race track' into the 'Enter a description of your school' text area
    When I submit the form
  )
end

Given "I have completed the Access needs support step" do
  steps %(
    Given I am on the 'Access needs support' page
    And I choose 'Yes' from the 'Do you want to add details about how you can support candidates with disabilities and access needs?' radio buttons
    When I submit the form
  )
end

Given "I have completed the Access needs detail step" do
  steps %(
    Given I am on the 'Access needs detail' page
    When I submit the form
  )
end

Given "I have completed the Disability confident step" do
  steps %(
    Given I am on the 'Disability Confident' page
    And I choose 'Yes' from the 'Are you signed up to the Disability Confident employer scheme?' radio buttons
    When I submit the form
  )
end

Given "I have completed the Access needs policy step" do
  steps %(
    Given I am on the 'Access needs policy' page
    And I choose 'Yes' from the 'Do you have any online information which covers your disability and access needs policy?' radio buttons
    And I enter 'https://example.com' into the 'Enter web address.' text area
    When I submit the form
  )
end

Given "I have completed the Candidate dress code step" do
  steps %(
    Given I am on the 'Candidate dress code' page
    And I check 'Business dress'
    And I check 'Other'
    And I enter 'Must have nice hat' into the 'For example no denim, jeans, shorts, short skirts or trainers.' text area
    When I submit the form
  )
end

Given "I have completed the Candidate parking information step" do
  steps %(
    Given I choose 'No' from the 'Do you provide parking for candidates?' radio buttons
    And I enter 'Carpark next door' into the 'Provide details of where candidates can park near your school.' text area
    When I submit the form
  )
end

Given "I have completed the Candidate experience schedule step" do
  steps %(
    Given I am on the 'Candidate experience schedule' page
    And I enter '8:15 am' into the 'What is your start time for candidates?' text area
    And I enter '4:30 pm' into the 'What is your finish time for candidates?' text area
    And I choose 'No' from the 'Are your start and finish times flexible?' radio buttons
    When I submit the form
  )
end

Given "I have completed the Availability preference step" do
  steps %(
    Given I am on the 'Availability preference' page
    And I choose "If you're flexible on dates, describe your school experience availability." from the 'Enter school experience availability or fixed dates' radio buttons
    When I submit the form
  )
end

Given "I have completed the Availability description step" do
  steps %(
    Given I am on the 'Availability description' page
    Given I save the page
    And I enter 'Whenever really' into the 'Outline when you offer school experience at your school.' text area
    When I submit the form
  )
end

Given "I have completed the Experience Outline step" do
  steps %(
    Given I am on the 'Experience Outline' page
    And I enter 'A really good one' into the 'What kind of school experience do you offer?' text area
    When I submit the form
  )
end

Given "I have completed the Teacher training step" do
  steps %(
    Given I am on the 'Teacher training' page
    And I choose 'Yes' from the 'Do you run your own teacher training or have any links to teacher training organisations and providers?' radio buttons
    And I enter 'We run our own training' into the 'Provide details.' text area
    And I enter 'http://example.com' into the 'Enter a web address.' text area
    When I submit the form
  )
end

Given "I have completed the Admin contact step" do
  steps %(
    Given I am on the 'Admin contact' page
    And I enter '01234567890' into the 'UK telephone number' text area
    And I enter 'g.chalmers@springfield.edu' into the 'Email address' text area
    And I enter 's.skinner@springfield.edu' into the 'Secondary email address' text area
    When I submit the form
    Then I should be on the 'Profile' page
  )
end

Then "I should see a validation error message" do
  within '.govuk-error-summary' do
    expect(page).to have_content 'There is a problem'
  end
end

Then "the page should have the following summary list information:" do |table|
  table.raw.to_h.each do |key, value|
    expect(page).to have_text %r{#{key} #{value}}, normalize_ws: true
  end
end

Given "the primary phase is available" do
  FactoryBot.create :bookings_phase, :primary
end

Given "the secondary school phase is availble" do
  FactoryBot.create :bookings_phase, :secondary
end

Given "the college phase is availble" do
  FactoryBot.create :bookings_phase, :college
end

Given "there are some subjects available" do
  FactoryBot.create :bookings_subject, name: 'Maths'
end

Given "A school is returned from DFE sign in" do
  @school = Bookings::School.find_by(urn: 123_456) || FactoryBot.create(:bookings_school, urn: 123_456, name: "Some school")
end

Given "I have completed the following steps:" do |table|
  table.hashes.each do |row|
    step_name = row['Step name']
    extra     = row['Extra']

    if row['Extra'].present?
      step "I have completed the #{step_name} step, #{extra}"
    else
      step "I have completed the #{step_name} step"
    end
  end
end

And "I complete the candidate dress code form with invalid data" do
  steps %(
    Given I check 'Business dress'
    And I check 'Other'
  )
end

And "I complete the candidate dress code form with valid data" do
  steps %(
    Given I check 'Business dress'
    And I check 'Other'
    And I enter 'Must have nice hat' into the 'For example no denim, jeans, shorts, short skirts or trainers.' text area
  )
end

And "I complete the candidate parking details form with invalid data" do
  steps %(
    Given I choose 'No' from the 'Do you provide parking for candidates?' radio buttons
  )
end

And "I complete the candidate parking details form with valid data" do
  steps %(
    Given I choose 'No' from the 'Do you provide parking for candidates?' radio buttons
    And I enter 'Carpark next door' into the 'Provide details of where candidates can park near your school.' text area
  )
end

And "I complete the candidate experience form with invalid data" do
  steps %(
    Given I enter '8:15 am' into the 'What is your start time for candidates?' text area
    And I enter '4:30 pm' into the 'What is your finish time for candidates?' text area
  )
end

And "I complete the candidate experience form with valid data" do
  steps %(
    And I enter '8:15 am' into the 'What is your start time for candidates?' text area
    And I enter '4:30 pm' into the 'What is your finish time for candidates?' text area
    And I choose 'No' from the 'Are your start and finish times flexible?' radio buttons
  )
end

When "I click the {string} button for the {string} row" do |button, row|
  within "##{row.parameterize}" do
    click_on button
  end
end

Then "I should see the correctly-formatted school placement information I entered in the wizard" do
  within "#school-placement-info" do
    @school.school_profile.description_details.lines.reject(&:blank?).each do |line|
      expect(page).to have_css('p', text: line.strip)
    end
  end
end

Then "the age range should match what I entered in the wizard" do
  within "#school-phases" do
    {
      primary: 'Primary',
      secondary: 'Secondary (11 to 16)',
      college: '16 to 18'
    }.each do |k, v|
      expect(page).to have_content(v) if @school.school_profile.phases_list.public_send("#{k}?")
    end
  end
end

Then "all of the subjects I entered should be listed" do
  within "#school-subjects" do
    @school.school_profile.subject_ids.each do |subject_id|
      expect(page).to have_content(Bookings::Subject.find(subject_id).name)
    end
  end
end

Then "I should see the teacher training info I entered in the wizard" do
  within '#teacher-training' do
    expect(page).to have_content \
      @school.school_profile.teacher_training.teacher_training_details

    expect(page).to have_link "Find out more about our teacher training",
      href: @school.school_profile.teacher_training.teacher_training_url
  end
end

Then "I should see the schools availability information" do
  within "#placement-availability" do
    expect(page).to have_css('p', text: @school.availability_info)
  end
end

Then "the DBS Check information in the sidebar should match the information entered in the wizard" do
  within "#dbs-check-info-sidebar" do
    expect(page).to have_content "Yes. Always require DBS check"
  end
end

Then "I should see the fee information I entered in the wizard" do
  within "#other-fee-info" do
    expect(page).to have_content "£300.00 Daily, Gold sovereigns\nFalconry lessons"
  end
end

Then "I should see the dress code policy information I entered in the wizard" do
  within "#dress-code" do
    expect(page).to have_content "Business dress\nMust have nice hat"
  end
end

Then "I should see the accessability information I have entered" do
  within('#disability-and-access') do
    expect(page).to have_css('dt', text: 'Disability and access details')

    within('#access-needs-statement') do
      expect(page).to have_text "We offer facilities and provide an inclusive environment for students, staff and school experience candidates with disability and access needs. We're happy to discuss your disability or access needs before or as part of your school experience request. Access needs policy", normalize_ws: true
    end
  end
end
