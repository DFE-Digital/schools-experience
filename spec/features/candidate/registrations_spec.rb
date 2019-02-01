require 'rails_helper'

feature 'Candidate Registrations', type: :feature do
  let! :today do
    Date.today
  end

  let! :tomorrow do
    today + 1.day
  end

  scenario 'Navigate to registrations/placements/new' do
    visit '/candidate/registrations/placements/new'

    expect(page).to have_text 'Request school experience placement'
  end

  scenario 'Submit registrations/placements form with errors' do
    visit '/candidate/registrations/placements/new'

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

  scenario 'Submit registrations/placements form successfully' do
    visit '/candidate/registrations/placements/new'

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

    expect(page.current_path).to eq '/candidate/registrations/account_checks/new'
  end

  scenario 'Submit account checks form with errors' do
    visit '/candidate/registrations/account_checks/new'

    fill_in 'Full name', with: 'testy mctest'

    click_button 'Continue'

    expect(page).to have_text 'There is a problem'
  end

  scenario 'Submit account checks form successfully' do
    visit '/candidate/registrations/account_checks/new'

    fill_in 'Full name', with: 'testy mctest'
    fill_in 'Email address', with: 'test@example.com'

    click_button 'Continue'

    expect(page.current_path).to eq '/candidate/registrations/personal_details/new'
  end

  scenario 'Submit registrations/personal_details form with errors' do
    visit '/candidate/registrations/personal_details/new'

    fill_in 'Building', with: 'Test house'
    fill_in 'Street', with: 'Test street'
    fill_in 'Town or city', with: 'Test Town'
    fill_in 'County', with: 'Testshire'
    fill_in 'Postcode', with: 'TE57 1NG'

    click_button 'Continue'

    expect(page).to have_text "There is a problem"
  end

  scenario 'Submit registrations/personal_details form successfully' do
    visit '/candidate/registrations/personal_details/new'

    fill_in 'Building', with: 'Test house'
    fill_in 'Street', with: 'Test street'
    fill_in 'Town or city', with: 'Test Town'
    fill_in 'County', with: 'Testshire'
    fill_in 'Postcode', with: 'TE57 1NG'
    fill_in 'UK telephone number', with: '01234567890'

    click_button 'Continue'

    expect(page.current_path).to eq '/candidate/registrations/account_infos/new'
  end

  scenario 'Submit registrations/account-info form with errors' do
    visit '/candidate/registrations/account_infos/new'

    choose 'Graduate or postgraduate'
    select 'Physics', from: 'Select the nearest or equivalent option'
    choose 'I want to become a teacher'
    select 'Physics', from: 'First choice'

    click_button 'Continue'

    expect(page).to have_text "There is a problem"
  end

  scenario 'Submit registrations/account-info form successfully' do
    visit '/candidate/registrations/account_infos/new'

    choose 'Graduate or postgraduate'
    select 'Physics', from: 'Select the nearest or equivalent option'
    choose 'I want to become a teacher'
    select 'Physics', from: 'First choice'
    select 'Mathematics', from: 'Second choice'

    click_button 'Continue'

    expect(page.current_path).to eq '/candidate/registrations/dbs_checks/new'
  end

  scenario 'Submit registrations/dbs_checks/new' do
    visit '/candidate/registrations/dbs_checks/new'

    choose 'Yes'

    click_button 'Continue'

    expect(page.current_path).to eq '/candidate/registrations/placement_request'
  end
end
