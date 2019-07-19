Given("I make my teaching preference selection") do
  choose "I’m very sure and think I’ll apply"
  select 'Physics', from: 'First choice'
  select 'Mathematics', from: 'Second choice'
end

Given("I have completed the Teaching preference step") do
  step "I am on the 'teaching preference' page for my school of choice"
  step 'I make my teaching preference selection'
  step 'I submit the form'
end

Given("I change my teaching subject") do
  choose "I’m not sure and finding out more"
end
