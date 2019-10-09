Given "there is a school called {string}" do |name|
  @school = FactoryBot.create(:bookings_school, :full_address, name: name, urn: 123456)
  expect(@school).to be_persisted
end

Given "my school of choice exists" do
  step "there is a school called 'Test School'"
end

Given "the school has subjects" do
  step "the school offers 'Maths, Physics, Biology'"
end

Given "the school offers {string}" do |subject_names|
  subject_names.split(', ').each do |subject_name|
    subject = Bookings::Subject.find_by(name: subject_name) || FactoryBot.create(:bookings_subject, name: subject_name)
    @school.subjects << subject
  end
end

Given "the school offers {int} subjects" do |int|
  @school.subjects << @subjects.first(int)
  expect(@school.subjects.size).to eql(int)
end

Given "the school is a {string} school" do |phase_name|
  @school.phases << Bookings::Phase.find_by(name: phase_name)
end

Given "the school is a {string} and {string} school" do |p1, p2|
  [p1, p2].each do |phase_name|
    @school.phases << Bookings::Phase.find_by(name: phase_name)
  end
end

Given "my chosen school has the URN {int}" do |int|
  @school.update_attributes(urn: int)
  expect(@school.urn).to eql(int)
end

Given("my school is a {string} school") do |phase|
  case phase
  when 'primary'
    @school.phases << FactoryBot.create(:bookings_phase, :primary)
  when 'secondary'
    @school.phases << FactoryBot.create(:bookings_phase, :secondary)
  when 'primary and secondary'
    @school.phases << FactoryBot.create(:bookings_phase, :primary)
    @school.phases << FactoryBot.create(:bookings_phase, :secondary)
  else
    fail "unsupported phase #{phase}"
  end
end
