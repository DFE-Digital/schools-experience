Then("there should be some information explaining why my contact details are needed") do
  expect(page).to have_content(
    "Register your details with us so you can get school experience placements"
  )
end
