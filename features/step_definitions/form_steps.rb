Then("I should see a form with the following fields:") do |table|
  within('#main-content form') do
    table.hashes.each do |row|
      label_text = row['Label']
      options = row['Options']&.split(',')&.map(&:strip)

      within(get_form_group(page, label_text)) do
        case row['Type']
        when 'date' then ensure_date_field_exists(page)
        when /radio/ then ensure_radio_buttons_exist(page, options)
        when /select/ then ensure_select_options_exist(page, options)
        else # regular inputs
          expect(page).to have_field(label_text, type: row['Type'])
        end
      end
    end
  end
end

When("I submit the form") do
  within('#main-content form') do
    click_on "Continue"
  end
end

Then("I should see radio buttons for {string} with the following options:") do |string, table|
  ensure_radio_buttons_exist(
    get_form_group(page, string),
    table.raw.flatten.to_a
  )
end

Then("I should see a select box labelled {string} with the following options:") do |string, table|
  ensure_select_options_exist(
    get_form_group(page, string),
    table.raw.flatten.to_a
  )
end

Given("there should be a hint stating {string}") do |string|
  expect(page).to have_css('.govuk-hint', text: string)
end

Then("I should see a select box containing degree subjects labelled {string}") do |string|
  @degree_subjects ||= YAML
    .load_file("#{Rails.root}/config/candidate_form_options.yml")['DEGREE_SUBJECTS']
    .sample(10) # we don't need all of them, just pick out 10
  ensure_select_options_exist(get_form_group(page, string), @degree_subjects)
end

Then("I fill in the date field {string} with {int}-{int}-{int}") do |field, day, month, year|
  within(page.find('.govuk-label', text: field).ancestor('.govuk-form-group')) do
    fill_in 'Day',   with: day
    fill_in 'Month', with: month
    fill_in 'Year',  with: year
  end
end

Given("I have entered the following details into the form:") do |table|
  table.raw.to_h.each do |field, value|
    fill_in field, with: value
  end
end

Given("I choose {string} from the {string} radio buttons") do |option, field|
  within(get_form_group(page, field)) do
    choose option
  end
end

def get_form_group(page, label_text)
  if page.has_css?(".govuk-label", text: label_text)
    page.find(".govuk-label", text: label_text).ancestor('div.govuk-form-group')
  else
    page.find("legend", text: label_text).ancestor('div.govuk-form-group')
  end
end

def ensure_date_field_exists(form_group)
  %w{Day Month Year}.each do |date_part|
    form_group.find('label', text: date_part).tap do |inner_label|
      expect(form_group).to have_field(inner_label.text, type: 'number')
    end
  end
end

def ensure_radio_buttons_exist(form_group, options)
  options.each { |option| expect(form_group).to have_field(option, type: 'radio') }
end

def ensure_select_options_exist(form_group, options)
  options.each { |option| expect(form_group).to have_css('select option', text: option) }
end
