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
end
