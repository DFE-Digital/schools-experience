Given("I make my degree selection") do
  choose 'Graduate or postgraduate'
  select 'Physics', from: 'What subject are you studying?'
end

Given("I have completed the Education step") do
  steps %(
    Given I am on the 'education' page for my school of choice
    And I make my degree selection
    When I submit the form
  )
end

Given("I change my degree selection") do
  choose 'First year'
end
