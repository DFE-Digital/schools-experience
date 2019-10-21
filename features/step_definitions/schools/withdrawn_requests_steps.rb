Given("there are some withdrawn requests") do
  step "there are 3 withdrawn requests"
end

And("there is/are {int} withdrawn requests") do |count|
  unless @school.subjects.where(name: 'Biology').any?
    @school.subjects << FactoryBot.create(:bookings_subject, name: 'Biology')
  end

  @withdrawn_requests = (1..count).map do |_index|
    FactoryBot.create(
      :placement_request,
      :with_a_fixed_date,
      :cancelled,
      school: @school,
    )
  end

  @withdrawn_request = @withdrawn_requests.first
  @first_placement_date = @withdrawn_request.placement_date.date.to_formatted_s(:govuk)
  @withdrawn_request_id = @withdrawn_request.id
end

Then("I should see the withdrawn requests listed") do
  within("#withdrawn-requests") do
    expect(page).to have_css('.withdrawn-request', count: 3)
  end
end

Given("there are some withdrawn requests belonging to other schools") do
  school = FactoryBot.create(:bookings_school, :with_subjects)

  @other_school_requests = FactoryBot.create_list(:placement_request, 2, :cancelled, school: school)

  @other_school_requests.each do |pr|
    expect(pr.school).not_to eql(@school)
  end
end

Then("every withdrawn request should contain a link to view more details") do
  within('#withdrawn-requests') do
    @withdrawn_requests.each do |placement_request|
      within(".withdrawn-request[data-placement-request-id='#{placement_request.id}']") do
        expect(page).to have_link('View', href: schools_withdrawn_request_path(placement_request.id))
      end
    end
  end
end

Given("there are no withdrawn requests") do
  # do nothing
end

Then("I should not see the requests table") do
  expect(page).not_to have_css('table#withdrawn-requests')
end

Then("the withdrawn requests date should be correct") do
  within('table#withdrawn-requests') do
    within(page.find('tbody').all('tr').first) do
      expect(page).to have_css('td', text: @first_placement_date)
    end
  end
end

Then("I should only see withdrawn requests belonging to my school") do
  within('table#withdrawn-requests tbody') do
    @withdrawn_requests.map(&:id).each do |request_id|
      expect(page).to have_css(".withdrawn-request[data-placement-request-id='#{request_id}']")
    end
    @other_school_requests.map(&:id).each do |request_id|
      expect(page).not_to have_css(".withdrawn-request[data-placement-request-id='#{request_id}']")
    end
  end
end

Given("there is at least one withdrawn request") do
  step "there is 1 withdrawn requests"
end

Given("I am viewing the withdrawn request") do
  path = path_for('withdrawn request', placement_request: @withdrawn_request)

  visit(path)
  expect(page.current_path).to eql(path)
end
