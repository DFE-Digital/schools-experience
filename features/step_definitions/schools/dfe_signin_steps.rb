Given("I am logged in as a DfE user") do
  visit insecure_auth_callback_path
  @school = Bookings::School.find_by(urn: 123456)
end
