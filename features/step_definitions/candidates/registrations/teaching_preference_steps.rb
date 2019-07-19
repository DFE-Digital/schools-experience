Given("I make my teaching preference selection") do
  choose "I’m very sure and think I’ll apply"
  select 'Physics', from: 'First choice'
  select 'Mathematics', from: 'Second choice'
end

Given("I have completed the Teaching preference step") do
  steps %(
    I have completed the Teaching preference step
    I make my teaching preference selection
    I submit the form
  )
end

Given("I change my teaching subject") do
  choose "I’m not sure and finding out more"
end
