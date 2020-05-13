Given("my school is set to use {string} dates") do |option|
  fail 'must be fixed or flexible' unless option.in?(%w[fixed flexible])

  @school.update(availability_preference_fixed: availability_preference_flag?(option))
end

Then("my school's availability preference should be {string}") do |option|
  if availability_preference_flag?(option)
    expect(@school).to be_availability_preference_fixed
  else
    expect(@school).not_to be_availability_preference_fixed
  end
end

def availability_preference_flag?(option)
  option == 'fixed'
end
