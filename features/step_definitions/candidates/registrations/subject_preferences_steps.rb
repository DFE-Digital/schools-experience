Given("I make my degree and teaching preference selections") do
  choose 'Graduate or postgraduate'
  select 'Physics', from: 'If you have or are studying for a degree, tell us about your degree subject'
  choose 'I want to become a teacher'
  select 'Physics', from: 'First choice'
  select 'Mathematics', from: 'Second choice'
end
