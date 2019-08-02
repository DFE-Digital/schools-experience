Then("I should see a paragraph informing me that my details will be used to identify me") do
  within('#main-content') do
    expect(page).to have_content \
      "Provide the following information so we can check if we already have your details."
  end
end

Then("the {string} date field should have day, month and year birth date auto-completion enabled") do |date_label|
  date_field_set = page.find('.govuk-fieldset__heading', text: date_label)

  within(date_field_set.ancestor('.govuk-form-group')) do
    %w(day month year).each do |part|
      expect(page).to have_css("input[autocomplete='bday bday-#{part}']")
    end
  end
end
