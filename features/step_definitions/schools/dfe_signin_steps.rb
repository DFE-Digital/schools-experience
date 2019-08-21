include DFESignInAPI

Given("I am logged in as a DfE user") do
  stub_dfe_sign_in_organisations

  visit insecure_auth_callback_path
  @school = Bookings::School.find_by(urn: 123456)
end

Given("my school is fully-onboarded") do
  if @school.profile.blank?
    FactoryBot.create(:bookings_profile, school: @school)
  end
end
