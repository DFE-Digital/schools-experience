Given("my school is enabled") do
  @school.update(enabled: true)
  expect(@school).to be_enabled
end

Given("my school is disabled") do
  expect(@school).to be_disabled
end

Then("my school should be enabled") do
  expect(@school.reload).to be_enabled
end

Then("my school should be disabled") do
  expect(@school.reload).to be_disabled
end
