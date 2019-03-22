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
    11048
  end

  let :school do
    double Candidates::School, name: 'Test School'
  end

  let :uuid do
    'some-uuid'
  end

  let :registration_session do
    FactoryBot.build :registration_session, current_time: today
  end

  before do
    allow(Candidates::School).to receive(:find) { school }

    allow(SecureRandom).to receive(:urlsafe_base64) { uuid }

    allow(NotifyEmail::CandidateMagicLink).to receive :new do
      double NotifyEmail::CandidateMagicLink, despatch!: true
    end

    allow(NotifyEmail::SchoolRequestConfirmation).to receive :new do
      double NotifyEmail::SchoolRequestConfirmation, despatch!: true
    end

    allow(NotifyEmail::CandidateRequestConfirmation).to receive :new do
      double NotifyEmail::CandidateRequestConfirmation, despatch!: true
    end
  end

  scenario 'Candidate Registraion Journey' do
    # Begin wizard journey
    visit "/candidates/schools/#{school_urn}/registrations/placement_preference/new"
    expect(page).to have_text 'Request school experience'

    # Submit registrations/placement_preference form with errors
    fill_in 'What do you want to get out of your school experience?', with: 'I enjoy teaching'
    click_button 'Continue'
    expect(page).to have_text 'There is a problem'

    # Submit registrations/placement_preference form successfully
    fill_in 'Is there anything schools need to know about your availability for school experience?', with: 'Only free from Epiphany to Whitsunday'
    fill_in 'What do you want to get out of your school experience?', with: 'I enjoy teaching'
    click_button 'Continue'
    expect(page.current_path).to eq \
      "/candidates/schools/#{school_urn}/registrations/contact_information/new"

    # Submit contact information form with errors
    fill_in 'Full name', with: 'testy mctest'
    click_button 'Continue'
    expect(page).to have_text 'There is a problem'

    # Submit contact information form successfully
    fill_in 'Full name', with: 'testy mctest'
    fill_in 'Email address', with: 'test@example.com'
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
    select 'Physics', from: 'If you have or are studying for a degree, tell us about your degree subject'
    choose "I’m very sure and think I’ll apply"
    select 'Maths', from: 'Second choice'
    click_button 'Continue'
    expect(page).to have_text "There is a problem"

    # Submit registrations/subject_preference form successfully
    choose 'Graduate or postgraduate'
    select 'Physics', from: 'If you have or are studying for a degree, tell us about your degree subject'
    choose "I’m very sure and think I’ll apply"
    select 'Physics', from: 'First choice'
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
    expect(page).to have_text "School or college #{school.name}"
    expect(page).to have_text 'Experience availability Only free from Epiphany to Whitsunday'
    expect(page).to have_text "Experience outcome I enjoy teaching"
    expect(page).to have_text "Degree stage Graduate or postgraduate"
    expect(page).to have_text "Degree subject Physics"
    expect(page).to have_text "I’m very sure and think I’ll apply"
    expect(page).to have_text "Teaching subject - first choice Physics"
    expect(page).to have_text "Teaching subject - second choice Maths"
    expect(page).to have_text "DBS certificate Yes"

    # Submit email confirmation form with errors
    click_button 'Accept and send'
    expect(page).to have_text 'You need to confirm your details are correct and accept our privacy policy to continue'
    expect(page).not_to have_text \
      "Click the link in the email we’ve sent to the following email address to verify your request for school experience at Test School:\ntest@example.com"

    # Submit email confirmation form successfully
    check \
      "By checking this box and sending this request you’re confirming, to the best of your knowledge, the details you’re providing are correct and you accept our privacy policy"
    click_button 'Accept and send'
    expect(page).to have_text \
      "Click the link in the email we’ve sent to the following email address to verify your request for school experience at Test School:\ntest@example.com"

    # Click email confirmation link
    visit \
      "/candidates/schools/#{school_urn}/registrations/placement_request/new?uuid=#{uuid}"

    expect(page).to have_text \
      "Your request for school experience will be forwarded to Test School."
  end
end
