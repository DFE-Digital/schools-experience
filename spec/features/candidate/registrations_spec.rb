require 'rails_helper'

feature 'Candidate Registrations', type: :feature do
  let! :today do
    Date.today
  end

  let! :tomorrow do
    today + 1.day
  end

  scenario 'Navigate to registrations/placement_preference/new' do
    visit '/candidate/registrations/placement_preference/new'

    expect(page).to have_text 'Request school experience placement'
  end

  scenario 'Submit registrations/placement_preference form with errors' do
    visit '/candidate/registrations/placement_preference/new'

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
  end

  scenario 'Submit registrations/placement_preference form successfully' do
    visit '/candidate/registrations/placement_preference/new'

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

    expect(page.current_path).to eq '/candidate/registrations/account_check/new'
  end

  scenario 'Submit account checks form with errors' do
    visit '/candidate/registrations/account_check/new'

    fill_in 'Full name', with: 'testy mctest'

    click_button 'Continue'

    expect(page).to have_text 'There is a problem'
  end

  scenario 'Submit account checks form successfully' do
    visit '/candidate/registrations/account_check/new'

    fill_in 'Full name', with: 'testy mctest'
    fill_in 'Email address', with: 'test@example.com'

    click_button 'Continue'

    expect(page.current_path).to eq '/candidate/registrations/address/new'
  end

  scenario 'Submit registrations/address form with errors' do
    visit '/candidate/registrations/address/new'

    fill_in 'Building', with: 'Test house'
    fill_in 'Street', with: 'Test street'
    fill_in 'Town or city', with: 'Test Town'
    fill_in 'County', with: 'Testshire'
    fill_in 'Postcode', with: 'TE57 1NG'

    click_button 'Continue'

    expect(page).to have_text "There is a problem"
  end

  scenario 'Submit registrations/address form successfully' do
    visit '/candidate/registrations/address/new'

    fill_in 'Building', with: 'Test house'
    fill_in 'Street', with: 'Test street'
    fill_in 'Town or city', with: 'Test Town'
    fill_in 'County', with: 'Testshire'
    fill_in 'Postcode', with: 'TE57 1NG'
    fill_in 'UK telephone number', with: '01234567890'

    click_button 'Continue'

    expect(page.current_path).to eq '/candidate/registrations/subject_preference/new'
  end

  scenario 'Submit registrations/subject_preference form with errors' do
    visit '/candidate/registrations/subject_preference/new'

    choose 'Graduate or postgraduate'
    select 'Physics', from: 'Select the nearest or equivalent option'
    choose 'I want to become a teacher'
    select 'Physics', from: 'First choice'

    click_button 'Continue'

    expect(page).to have_text "There is a problem"
  end

  scenario 'Submit registrations/subject_preferenc form successfully' do
    visit '/candidate/registrations/subject_preference/new'

    choose 'Graduate or postgraduate'
    select 'Physics', from: 'Select the nearest or equivalent option'
    choose 'I want to become a teacher'
    select 'Physics', from: 'First choice'
    select 'Mathematics', from: 'Second choice'

    click_button 'Continue'

    expect(page.current_path).to eq \
      '/candidate/registrations/background_check/new'
  end

  scenario 'Submit registrations/background_check/new' do
    visit '/candidate/registrations/background_check/new'

    choose 'Yes'

    click_button 'Continue'

    expect(page.current_path).to eq '/candidate/registrations/placement_request'
  end
end
