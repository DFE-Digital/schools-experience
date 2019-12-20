Given("there are some upcoming requests") do
  step 'there are some placement requests'
end

Given("there are some placement requests") do
  @placement_requests = FactoryBot.create_list \
    :placement_request,
    5,
    school: @school,
    created_at: '2094-01-01',
    teaching_stage: 'I’ve applied for teacher training',
    availability: 'Any time during July 2094'
end

Given("there is at least one placement request") do
  @placement_request = FactoryBot.create \
    :placement_request,
    school: @school,
    created_at: '2094-02-08',
    availability: 'Any time during November 2019',
    teaching_stage: 'I’ve applied for teacher training',
    has_dbs_check: true,
    objectives: 'To learn different teaching styles and what life is like in a classroom.',
    degree_stage: 'Final year',
    degree_subject: 'Law'
end

Given("there is at least one subject-specific placement request for {string}") do |subject_name|
  @requested_subject = Bookings::Subject.find_by(name: subject_name)

  @placement_date = FactoryBot.build(
    :bookings_placement_date,
    bookings_school: @school,
    subject_specific: true,
    supports_subjects: true
  ).tap do |pd|
    pd.subjects << @requested_subject
    pd.save
  end

  @placement_request = FactoryBot.create \
    :placement_request,
    school: @school,
    created_at: '2094-02-08',
    availability: 'Any time during November 2019',
    teaching_stage: 'I’ve applied for teacher training',
    has_dbs_check: true,
    objectives: 'To learn different teaching styles and what life is like in a classroom.',
    degree_stage: 'Final year',
    degree_subject: 'Law',
    bookings_placement_date_id: @placement_date.id,
    bookings_subject_id: @requested_subject.id
end

When("I am on a placement request page") do
  visit path_for 'placement request', placement_request: @placement_request
end

Given("the subjects {string} and {string} exist") do |subj1, subj2|
  [subj1, subj2].each { |s| FactoryBot.create(:bookings_subject, name: s) }
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
      within(".placement-request[data-placement-request='#{placement_request.id}']") do
        expect(page).to have_link('View', href: schools_placement_request_path(placement_request.id))
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

Then("I should see a table with the following headings:") do |table|
  table.transpose.raw.flatten.each do |heading|
    expect(page).to have_css('thead th', text: heading)
  end
end

Given("there are some cancelled placement requests") do
  @cancelled_placement_requests_count = 3
  @cancelled_placement_requests = FactoryBot.create_list \
    :placement_request,
    @cancelled_placement_requests_count,
    :cancelled,
    school: @school
end

Then("the cancelled requests should have a status of {string}") do |status|
  within('table#placement-requests') do
    expect(page).to have_css('.govuk-tag-red', text: /#{status}/i, count: @cancelled_placement_requests_count)
  end
end

Given("there are some unviewed placement requests") do
  @unviewed_placement_requests_count = 3
  @unviewed_placement_requests = FactoryBot.create_list \
    :placement_request,
    @unviewed_placement_requests_count,
    school: @school
end

Then("the unviewed requests should have a status of {string}") do |status|
  within('table#placement-requests') do
    expect(page).to have_css('.govuk-tag', text: /#{status}/i, count: @unviewed_placement_requests_count)
  end
end

Given("there are some viewed placement requests") do
  @viewed_placement_requests_count = 3
  @viewed_placement_requests = FactoryBot.create_list \
    :placement_request,
    @viewed_placement_requests_count,
    school: @school,
    viewed_at: 3.minutes.ago
end

Then("the viewed requests should have no status") do
  within('table#placement-requests') do
    expect(page).not_to have_css('.govuk-tag')
  end
end

Given("the request has been withdrawn") do
  FactoryBot.create :cancellation,
    :sent,
    :cancelled_by_candidate,
    placement_request: @placement_request

  @placement_request.reload
end

Given("the request has been rejected") do
  FactoryBot.create :cancellation,
    :sent,
    :cancelled_by_school,
    placement_request: @placement_request,
    extra_details: 'Better luck next time'

  @placement_request.reload
end

Then("I should see the withdrawal details") do
  expect(page).to have_css 'h1', text: "Matthew Richards has withdrawn their request"

  within '#cancellation-details' do
    expect(page).to have_text @placement_request.candidate_cancellation.reason
  end
end

Then("I should see the rejection details") do
  expect(page).to have_css 'h1', text: "This request from Matthew Richards has been rejected"

  within '#cancellation-details' do
    expect(page).to have_text @placement_request.school_cancellation.rejection_description
    expect(page).to have_text @placement_request.school_cancellation.extra_details
  end
end

Then("I should see the withdrawn details with the following values:") do |table|
  within "section#cancellation-details" do
    expect(page).to have_css('h2', text: 'Withdrawal details')

    table.hashes.each do |row|
      expect(page).to have_css('dt', text: row['Heading'])
      expect(page).to have_css('dd', text: /#{row['Value']}/i)
    end
  end
end
