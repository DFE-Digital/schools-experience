Then("my school's availabiltiy info should have been updated") do
  expect(@school.reload.availability_info).to eql(@filled_in_value)
end
