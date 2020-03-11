Given("there are some bookings with attendance recorded") do
  biology = FactoryBot.create :bookings_subject, name: 'Biology'

  FactoryBot.create :bookings_booking, :accepted, :previous, :attended,
    bookings_school: @school,
    bookings_subject: biology

  FactoryBot.create :bookings_booking, :accepted, :previous, :unattended,
    bookings_school: @school,
    bookings_subject: biology
end

Given("there are no bookings with attendance recorded") do
  FactoryBot.create :bookings_subject, name: 'Biology'
  FactoryBot.create :bookings_booking, :accepted, :previous,
    bookings_school: @school
end

Then("I should not see the attendances table") do
  within("#attendances-container") do
    expect(page).to have_css('.booking', count: 0)
    expect(page).to have_css('p', text: /no attendance/i)
  end
end
