Given("I have completed the 'review and send email' page") do
  steps %(
    Given I have progressed to the 'review and send email' page for my chosen placement request
    And I enter '#{@candidate_instructions}' into the 'Candidate instructions' field
    When I submit the form
    Then I should be on the 'preview confirmation email' page for my chosen placement request
  )
end

Then("the extra details from the school section should contain the relevant information") do
  within('#extra-details-from-the-school') do
    expect(page).to have_content(@candidate_instructions)
  end
end


Given("I think the email looks good") do
  # do nothing
end

Then("the placement request should be accepted") do
    pending # Write code here that turns the phrase above into concrete actions
end
