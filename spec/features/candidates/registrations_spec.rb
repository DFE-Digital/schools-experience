require 'rails_helper'

feature 'Candidate Registrations', type: :feature do
  let! :today do
    Date.today
  end

  let! :tomorrow do
    today + 1.day
  end

  let! :today_in_words do
    today.strftime '%d %B %Y'
  end

  let! :tomorrow_in_words do
    tomorrow.strftime '%d %B %Y'
  end

  let! :school_urn do
    'URN'
  end

  let :subjects do
    [
      { name: 'Mathematics' },
      { name: 'Physics' }
    ]
  end

  let :school do
    double Candidates::School, subjects: subjects
  end

  before do
    allow(Candidates::School).to receive(:find) { school }
  end

  scenario 'Candidate Registraion Journey' do
    # Begin wizard journey
    visit "/candidates/schools/#{school_urn}/registrations/placement_preference/new"
    expect(page).to have_text 'Request school experience placement'

    # Submit registrations/placement_preference form with errors
    within all('.govuk-date-input')[0] do
      fill_in 'Day',   with: today.day
      fill_in 'Month', with: today.month
      fill_in 'Year',  with: today.year
    end

    within all('.govuk-date-input')[1] do
      fill_in 'Day',   with: tomorrow.day
      fill_in 'Month', with: tomorrow.month
      fill_in 'Year',  with: tomorrow.year
    end

    fill_in 'Explain in 50 words or fewer', with: 'I enjoy teaching'
    click_button 'Continue'
    expect(page).to have_text 'There is a problem'

    # Submit registrations/placement_preference form successfully
    within all('.govuk-date-input')[0] do
      fill_in 'Day',   with: today.day
      fill_in 'Month', with: today.month
      fill_in 'Year',  with: today.year
    end

    within all('.govuk-date-input')[1] do
      fill_in 'Day',   with: tomorrow.day
      fill_in 'Month', with: tomorrow.month
      fill_in 'Year',  with: tomorrow.year
    end

    fill_in 'Explain in 50 words or fewer', with: 'I enjoy teaching'
    choose 'No'
    click_button 'Continue'
    expect(page.current_path).to eq \
      "/candidates/schools/#{school_urn}/registrations/account_check/new"

    # Submit account checks form with errors
    fill_in 'Full name', with: 'testy mctest'
    click_button 'Continue'
    expect(page).to have_text 'There is a problem'

    # Submit account checks form successfully
    fill_in 'Full name', with: 'testy mctest'
    fill_in 'Email address', with: 'test@example.com'
    click_button 'Continue'
    expect(page.current_path).to eq \
      "/candidates/schools/#{school_urn}/registrations/address/new"

    # Submit registrations/address form with errors
    fill_in 'Building', with: 'Test house'
    fill_in 'Street', with: 'Test street'
    fill_in 'Town or city', with: 'Test Town'
    fill_in 'County', with: 'Testshire'
    fill_in 'Postcode', with: 'TE57 1NG'
    click_button 'Continue'
    expect(page).to have_text "There is a problem"

    # Submit registrations/address form successfully
    fill_in 'Building', with: 'Test house'
    fill_in 'Street', with: 'Test street'
    fill_in 'Town or city', with: 'Test Town'
    fill_in 'County', with: 'Testshire'
    fill_in 'Postcode', with: 'TE57 1NG'
    fill_in 'UK telephone number', with: '01234567890'
    click_button 'Continue'
    expect(page.current_path).to eq \
      "/candidates/schools/#{school_urn}/registrations/subject_preference/new"

    # Submit registrations/subject_preference form with errors
    choose 'Graduate or postgraduate'
    select 'Physics', from: 'Select the nearest or equivalent option'
    choose 'I want to become a teacher'
    select 'Physics', from: 'First choice'
    click_button 'Continue'
    expect(page).to have_text "There is a problem"

    # Submit registrations/subject_preference form successfully
    choose 'Graduate or postgraduate'
    select 'Physics', from: 'Select the nearest or equivalent option'
    choose 'I want to become a teacher'
    select 'Physics', from: 'First choice'
    select 'Mathematics', from: 'Second choice'
    click_button 'Continue'
    expect(page.current_path).to eq \
      "/candidates/schools/#{school_urn}/registrations/background_check/new"

    # Submit registrations/background_check form with errors
    click_button 'Continue'
    expect(page).to have_text 'There is a problem'

    # Submit registrations/background_check form successfully
    choose 'Yes'
    click_button 'Continue'
    expect(page.current_path).to eq \
      "/candidates/schools/#{school_urn}/registrations/application_preview"

    # Expect preview to match the data we successfully submited
    expect(page).to have_text 'Full name testy mctest'
    expect(page).to have_text \
      'Address Test house, Test street, Test Town, Testshire, TE57 1NG'
    expect(page).to have_text 'UK telephone number 01234567890'
    expect(page).to have_text 'Email address test@example.com'
    expect(page).to have_text 'School or college SCHOOL_STUB'
    expect(page).to have_text \
      "Placement availability #{today_in_words} to #{tomorrow_in_words}"
    expect(page).to have_text "Placement outcome I enjoy teaching"
    expect(page).to have_text "Disability or access needs None"
    expect(page).to have_text "Degree stage Graduate or postgraduate"
    expect(page).to have_text "Degree subject Physics"
    expect(page).to have_text "Teaching stage I want to become a teacher"
    expect(page).to have_text "Teaching subject - first choice Physics"
    expect(page).to have_text "Teaching subject - second choice Mathematics"
    expect(page).to have_text "DBS check document Yes"

    # Submit placement request form successfully
    click_button 'Accept and send'
    expect(page).to have_text 'Your placement request has been sent'
  end
end
