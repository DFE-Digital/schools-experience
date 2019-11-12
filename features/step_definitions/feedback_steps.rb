Given("I am on the {string} page prior to giving feedback") do |string|
  path_for(string).tap do |p|
    visit(p)
    expect(page.current_path).to eql(p)
    @referrer = page.current_url
    expect(@referrer).to start_with('http')
  end
end

When("I click {string}, fill in and submit the candidate feedback form") do |string|
  click_link(string)
  steps %(
    When I choose 'Make a school experience request' from the 'What did you come to do on the service?' radio buttons
    And I choose 'Yes' from the 'Did you achieve what you wanted from your visit?' radio buttons
    And I choose 'Satisfied' from the 'Overall, how did you feel about the service you received?' radio buttons
    Then I click the 'Submit feedback' button
  )
end

When("I click {string}, fill in and submit the school feedback form") do |string|
  click_link(string)
  steps %(
    When I choose 'Set up a new school or schools on the service' from the 'What did you come to do on the service?' radio buttons
    And I choose 'Yes' from the 'Did you achieve what you wanted from your visit?' radio buttons
    And I choose 'Satisfied' from the 'Overall, how did you feel about the service you received?' radio buttons
    Then I click the 'Submit feedback' button
  )
end

Then("my referrer should have been recorded") do
  referrer_with_credentials = @referrer.gsub(/(https?:\/\/)([^\/]+@)?/, '\1')
  expect(Feedback.last.referrer).to match(referrer_with_credentials)
end
