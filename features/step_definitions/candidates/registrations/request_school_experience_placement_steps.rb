Then("the {string} word count should say {string}") do |label_text, expectation|
  within(page.find("label", text: label_text).ancestor('div.govuk-form-group')) do
    expect(page).to have_css("span.govuk-character-count__message", text: expectation)
  end
end

Then("the {string} section should have {string} and {string} radio buttons") do |section, option_one, option_two|
  within(".#{section.parameterize}") do
    ensure_radio_buttons_exist(page, [option_one, option_two])
  end
end

When("I click the {string} option in the {string} section") do |option, section|
  within(".#{section.parameterize}") do
    expect(choose(option)).to be_checked
  end
end

Given("there is no {string} text area") do |string|
  expect(page).not_to have_field(string, type: 'textarea')
end

Then("a text area labelled {string} should have appeared") do |string|
  expect(page).to have_field(string, type: 'textarea')
end

Given("I have filled in the form with accurate data") do
  fill_in "Tell us about your availability", with: "Anytime!"
  fill_in "What do you want to get out of your school experience?", with: "I love teaching"
end

Given("my school has availability information set") do
  @availability_info = "Tuesday afternoons only"
  @school ||= FactoryBot.create(:bookings_school)
  @school.update! availability_info: @availability_info
end

Then("I should see a warning containing the availability information") do
  within('section.govuk-se-warning') do
    expect(page).to have_content("The school has provided the following details about when school experience is available:")
    expect(page).to have_content(@availability_info)
  end
end

Given("my school has availability no information set") do
  @school ||= FactoryBot.create(:bookings_school)
  @school.update! availability_info: nil
end

Then("I should see no warning containing the availability information") do
  expect(page).not_to have_css('section.govuk-se-warning')
end

Given("the school I'm applying to is flexible on dates") do
  # do nothing, this is the default
end

Given("the school I'm applying to is not flexible on dates") do
  @school ||= FactoryBot.create(:bookings_school)
  @school.update! availability_preference_fixed: true

  (1..3).each { |i| i.weeks.from_now }.each do |date|
    @school.bookings_placement_dates.create(date: date.weeks.from_now, published_at: 1.week.ago)
    @wanted_bookings_placement_date = @school.bookings_placement_dates.last
  end
end


Then("there should be a radio button per date the school has specified") do
  @school.bookings_placement_dates.map(&:to_s).each do |date_string|
    expect(page).to have_field(date_string, type: 'radio')
  end
end

When("I choose a placement date") do
  @last_date = @school.bookings_placement_dates.last
  choose @last_date.to_s
end
