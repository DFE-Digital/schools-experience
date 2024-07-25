Given("I make my degree and teaching preference selections") do
  choose 'Graduate or postgraduate'
  select 'Physics', from: 'What subject are you studying?'
  choose 'I want to become a teacher'
  select 'Physics', from: 'First choice'
  select 'Mathematics', from: 'Second choice'
end

When("I choose {string} as my degree stage") do |string|
  choose string
end

Then("I should not see any subject choices") do
  expect(page).not_to have_field \
    'What subject are you studying?'
end

Then("I should see some subject choices") do
  expect(page).to have_field \
    'What subject are you studying?'
end
