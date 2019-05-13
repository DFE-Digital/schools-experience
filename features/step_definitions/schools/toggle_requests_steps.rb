Given("my school is enabled") do
  expect(@school).to be_enabled
end

Given("my school is disabled") do
  @school.update(enabled: false)
  expect(@school).to be_disabled
end

Then("my school should be enabled") do
  expect(@school.reload).to be_enabled
end

Then("my school should be disabled") do
  expect(@school.reload).to be_disabled
end
