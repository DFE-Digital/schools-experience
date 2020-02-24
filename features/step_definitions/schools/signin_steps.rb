Given("the School Chooser feature is enabled") do
  allow(Schools::ChangeSchool).to receive(:allow_school_change_in_app?) { true }
end

Given("I have two schools") do
  schoola = FactoryBot.create(:bookings_school, name: 'School A', urn: 123489)
  schoolb = FactoryBot.create(:bookings_school, name: 'School B', urn: 123490)

  allow_any_instance_of(Schools::DFESignInAPI::Organisations).to \
    receive(:uuids).and_return \
      SecureRandom.uuid => schoola.urn,
      SecureRandom.uuid => schoolb.urn

  allow_any_instance_of(Schools::DFESignInAPI::Roles).to \
    receive(:has_school_experience_role?).and_return(true)
end

Given("I am signed in as School A") do
  step "I am on the 'School chooser' page"
  step "I choose 'School A' from the 'Select your school' radio buttons"
  step "I click the 'Change school' submit button"
end
