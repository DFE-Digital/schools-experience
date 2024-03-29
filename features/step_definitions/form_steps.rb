Then("I should see a form with the following fields:") do |table|
  table.hashes.each do |row|
    label_text = row['Label']
    options = row['Options']&.split(',')&.map(&:strip)
    autocompletion = row['Autocompletion']

    within(get_form_group(page, label_text)) do
      case row['Type']
      when 'date' then ensure_date_field_exists(page)
      when /radio/ then ensure_radio_buttons_exist(page, options)
      when /select/ then ensure_select_options_exist(page, options)
      when /checkbox/ then ensure_check_boxes_exist(page, options)
      when /textarea/ then ensure_textarea_exists(page)
      else
        ensure_input_exists(page, label_text, row['Type'], autocomplete: autocompletion)
      end
    end
  end
end

When("I submit the form") do
  click_on "Continue"
end

Then("the submit button should contain text {string}") do |string|
  within('#main-content form') do
    expect(page).to have_button(string)
  end
end

Then("I should see radio buttons for {string} with the following options:") do |string, table|
  ensure_radio_buttons_exist(
    get_form_group(page, string),
    table.raw.flatten.to_a
  )
end

Then("I should see checkboxes for {string} with the following options:") do |string, table|
  ensure_check_boxes_exist(
    get_form_group(page, string),
    table.raw.flatten.to_a
  )
end

Then("I should not see {string}") do |string|
  expect(page).not_to have_content string
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

Then("the {string} field should contain hint {string}") do |label, hint|
  within(get_form_group(page, label)) do
    expect(page).to have_css('.govuk-hint', text: hint)
  end
end

Then("I should see a select box containing degree subjects labelled {string}") do |string|
  @degree_subjects ||= YAML
    .load_file(Rails.root.join('config', 'candidate_form_options.yml'))['DEGREE_SUBJECTS']
    .sample(10) # we don't need all of them, just pick out 10
  ensure_select_options_exist(get_form_group(page, string), @degree_subjects)
end

Then("I should see a select box containing school subjects labelled {string}") do |string|
  pending
  ensure_select_options_exist(get_form_group(page, string), @subjects.map(&:name))
end

Then("I fill in the date field {string} with {int}-{int}-{int}") do |field, day, month, year|
  date_field_set = page.find '.govuk-fieldset', text: field
  within(date_field_set.ancestor('.govuk-form-group')) do
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

Given("I enter {string} into the {string} field") do |value, field|
  fill_in field, with: value
end

Given("I choose {string} from the {string} radio buttons") do |option, field|
  within(get_form_group(page, field)) do
    choose option
  end
end

Given("I choose {string} from the {string} radio buttons if available") do |option, field|
  if page.has_css? ".govuk-fieldset__legend", text: field
    step "I choose '#{option}' from the '#{field}' radio buttons"
  end
end

Then("the {string} input should require at least {string} characters") do |field, length|
  input = page.find("input[name=#{field}]")
  expect(input['minlength']).to eql(length)
end

Then("I should see the validation error {string}") do |string|
  within ".govuk-error-summary" do
    expect(page).to have_text string
  end
end

Given("there should be a {string} text area") do |string|
  expect(page).to have_field(string, type: 'textarea')
end

Then("there should be a {string} checkbox") do |string|
  expect(page).to have_field(string, type: 'checkbox')
end

When("I check the {string} checkbox") do |string|
  check string
end

When("I uncheck the {string} checkbox") do |string|
  uncheck string
end

When("I enter {string} into the {string} text area") do |value, label|
  @filled_in_value = value
  fill_in label, with: value
end

When("I click the {string} submit button") do |string|
  page.find("button", text: string).click
end

Then("there should not be a {string} checkbox") do |label_text|
  expect(page).not_to have_css('label', text: label_text)
end

Then("{string} checkbox should be selected") do |label_text|
  expect(find(:checkbox, label_text)).to be_checked
end

Then("{string} radio button should be selected") do |label_text|
  expect(find(:radio_button, label_text)).to be_checked
end

Then("no radio buttons should be selected") do
  expect(page).not_to have_css('input[type="radio"][selected]')
end

def get_form_group(page, label_text)
  selector = get_selector label_text
  label = page.find(selector, text: label_text)
  label.ancestor('div.govuk-form-group')
end

def get_input(page, label_text)
  selector = get_selector label_text
  label = page.find(selector, text: label_text)
  page.find('input', id: label['for'])
end

LABEL_SELECTORS = %w[.govuk-label legend label].freeze
def get_selector(label_text)
  LABEL_SELECTORS.detect { |s| page.has_css?(s, text: label_text) }
end

def ensure_date_field_exists(form_group)
  %w[Day Month Year].each do |date_part|
    form_group.find('label', text: date_part).tap do |inner_label|
      expect(form_group).to have_field(inner_label.text)
    end
  end
end

def ensure_check_boxes_exist(form_group, options)
  options.each do |option|
    expect(form_group).to have_field(option, type: 'checkbox')
  end
end

def ensure_textarea_exists(form_group)
  expect(form_group).to have_css('textarea.govuk-textarea')
end

def ensure_radio_buttons_exist(form_group, options)
  options.each do |option|
    expect(form_group).to have_field(option, type: 'radio')
  end
end

def ensure_select_options_exist(form_group, options)
  options.each { |option| expect(form_group).to have_css('select option', text: option) }
end

def ensure_input_exists(form_group, label_text, field_type, autocomplete: nil)
  expect(form_group).to have_field(label_text, type: field_type)

  if autocomplete
    expect(form_group).to have_css("input[autocomplete='#{autocomplete}']")
  end
end

Then("there should be no {string} field") do |label|
  expect(page).not_to have_content(label)
end
