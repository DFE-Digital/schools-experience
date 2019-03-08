Given("I make my degree and teaching preference selections") do
  choose 'Graduate or postgraduate'
  select 'Physics', from: 'If you have or are studying for a degree, tell us about your degree subject'
  choose 'I want to become a teacher'
  select 'Physics', from: 'First choice'
  select 'Mathematics', from: 'Second choice'
end

When("I choose {string} as my degree stage") do |string|
  choose string
end

Then("I should not see any subject choices") do
  expect(page).not_to have_field \
    'If you have or are studying for a degree, tell us about your degree subject'
end

Then("I should see some subject choices") do
  expect(page).to have_field \
    'If you have or are studying for a degree, tell us about your degree subject'
end
