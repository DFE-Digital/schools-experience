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

    fill_in 'Start Date', with: today
    fill_in 'End Date',   with: tomorrow
    fill_in 'Objectives', with: 'I enjoy teaching'

    click_button 'Continue'

    expect(page).to have_text 'Please select an option'
  end

  scenario 'Submit registrations/placements form successfully' do
    visit '/candidate/registrations/placements/new'

    fill_in 'Start Date', with: today
    fill_in 'End Date',   with: tomorrow
    fill_in 'Objectives', with: 'I enjoy teaching'
    choose 'No'

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

    expect(page).to have_text "can't be blank"
  end

  scenario 'Submit registrations/personal_details form successfully' do
    visit '/candidate/registrations/personal_details/new'

    fill_in 'Building', with: 'Test house'
    fill_in 'Street', with: 'Test street'
    fill_in 'Town or city', with: 'Test Town'
    fill_in 'County', with: 'Testshire'
    fill_in 'Postcode', with: 'TE57 1NG'
    fill_in 'Phone', with: '01234567890'

    click_button 'Continue'

    expect(page.current_path).to eq '/candidate/registrations/account_infos/new'
  end

  scenario 'Submit registrations/account-info form with errors' do
    visit '/candidate/registrations/account_infos/new'

    choose 'Graduate or postgraduate'
    select 'Physics', from: 'Degree subject'
    choose 'I want to become a teacher'
    select 'Physics', from: 'Subject first choice'

    click_button 'Continue'

    expect(page).to have_text "can't be blank"
  end

  scenario 'Submit registrations/account-info form successfully' do
    visit '/candidate/registrations/account_infos/new'

    choose 'Graduate or postgraduate'
    select 'Physics', from: 'Degree subject'
    choose 'I want to become a teacher'
    select 'Physics', from: 'Subject first choice'
    select 'Mathematics', from: 'Subject second choice'

    click_button 'Continue'

    expect(page.current_path).to eq \
      '/candidate/registrations/background_and_security_checks/new'
  end
end
