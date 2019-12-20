Given("there are some rejected requests") do
  step "there are 3 rejected requests"
end

And("there is/are {int} rejected requests") do |count|
  unless @school.subjects.where(name: 'Biology').any?
    @school.subjects << FactoryBot.create(:bookings_subject, name: 'Biology')
  end

  @rejected_requests = (1..count).map do |_index|
    FactoryBot.create(
      :placement_request,
      :with_a_fixed_date,
      :cancelled_by_school,
      school: @school,
    )
  end

  @rejected_request = @rejected_requests.first
  @first_placement_date = @rejected_request.placement_date.date.to_formatted_s(:govuk)
  @rejected_request_id = @rejected_request.id
end

Then("I should see the rejected requests listed") do
  within("#rejected-requests") do
    expect(page).to have_css('.rejected-request', count: 3)
  end
end

Then("the rejected requests date should be correct") do
  within('table#rejected-requests') do
    within(page.find('tbody').all('tr').first) do
      expect(page).to have_css('td', text: @first_placement_date)
    end
  end
end

Given("there are some rejected requests belonging to other schools") do
  school = FactoryBot.create(:bookings_school, :with_subjects)

  @other_school_requests = FactoryBot.create_list(:placement_request, 2, :cancelled_by_school, school: school)

  @other_school_requests.each do |pr|
    expect(pr.school).not_to eql(@school)
  end
end

Then("I should only see rejected requests belonging to my school") do
  within('table#rejected-requests tbody') do
    @rejected_requests.map(&:id).each do |request_id|
      expect(page).to have_css(".rejected-request[data-placement-request-id='#{request_id}']")
    end
    @other_school_requests.map(&:id).each do |request_id|
      expect(page).not_to have_css(".rejected-request[data-placement-request-id='#{request_id}']")
    end
  end
end

Then("every rejected request should contain a link to view more details") do
  within('#rejected-requests') do
    @rejected_requests.each do |placement_request|
      within(".rejected-request[data-placement-request-id='#{placement_request.id}']") do
        expect(page).to have_link('View', href: schools_rejected_request_path(placement_request.id))
      end
    end
  end
end

Given("there are no rejected requests") do
  # do nothing
end

Given("there is at least one rejected request") do
  step "there is 1 rejected requests"
  @rejected_request.cancellation.update(rejection_category: :other, reason: 'MyText')
end

When("I am viewing the rejected request") do
  path = path_for('rejected request', placement_request: @rejected_request)

  visit(path)
  expect(page.current_path).to eql(path)
end

Given("a request has been rejected because of {string}") do |rejection_category|
  step %(there is 1 rejected requests)
  @cancellation = @rejected_request.cancellation.tap do |cancellation|
    cancellation.update(rejection_category: rejection_category)
  end
end

Then("I should see a rejected request with the rejection reason displayed") do
  expect(page).to have_css('td', text: 'We cannot support the date you have requested', count: 1)
end

Then("I should see a rejected request with the rejection reason displayed in full") do
  expect(page).to have_css('dd', text: 'We cannot support the date you have requested', count: 1)
end
