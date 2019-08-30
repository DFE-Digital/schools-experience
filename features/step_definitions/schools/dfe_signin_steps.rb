Given("I am logged in as a DfE user") do
  visit insecure_auth_callback_path
  @school ||= Bookings::School.find_by(urn: 123456)
end

Given("I see the candidate requirements screen") do
  if @school.school_profile.blank?
    FactoryBot.create(:school_profile, bookings_school: @school, show_candidate_requirements_selection: false)
  else
    @school.school_profile.update!(show_candidate_requirements_selection: false)
  end
end

Given("my school is fully-onboarded") do
  if @school.profile.blank?
    FactoryBot.create(:bookings_profile, school: @school)
  end
end
