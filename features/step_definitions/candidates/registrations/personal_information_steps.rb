Then("I should see a paragraph informing me that my details will be used to identify me") do
  within('#main-content') do
    expect(page).to have_content \
      "Provide the following information so we can check if we already have your details."
  end
end

Then("the {string} date field should have day, month and year birth date auto-completion enabled") do |date_label|
  date_field_set = page.find('.govuk-fieldset__heading', text: date_label)

  within(date_field_set.ancestor('.govuk-form-group')) do
    %w(Day Month Year).each do |part|
      label = page.find('label', text: part)
      input = page.find("input##{label[:for]}")
      expect(input[:autocomplete]).to eql("bday bday-#{part.downcase}")
    end
  end
end
