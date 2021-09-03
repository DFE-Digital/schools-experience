Then("I fill in the govuk date field {string} with {int}-{int}-{int}") do |field, day, month, year|
  # Some of the designs call for the field name to be styled as a heading
  # binding.pry
  date_field_set = \
    begin
      page.find 'legend', text: field
    rescue Capybara::ElementNotFound
      page.find '.govuk-fieldset__legend', text: field
    end

  within(date_field_set.ancestor('.govuk-form-group')) do
    fill_in 'Day',   with: day
    fill_in 'Month', with: month
    fill_in 'Year',  with: year
  end
end
