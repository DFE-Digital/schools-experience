require 'rails_helper'

feature 'Candidate Registrations', type: :feature do
  include_context 'Stubbed candidates school'

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

  let :uuid do
    SecureRandom.urlsafe_base64
  end

  let :registration_session do
    FactoryBot.build :registration_session, current_time: today, uuid: uuid
  end

  before do
    allow(Candidates::School).to receive(:find) { school }

    allow_any_instance_of(Candidates::Registrations::RegistrationSession).to \
      receive(:uuid).and_return(uuid)

    allow(NotifyEmail::CandidateMagicLink).to receive :new do
      double NotifyEmail::CandidateMagicLink, despatch_later!: true
    end
  end

  feature 'Candidate Registration' do
    context 'for unknown Contact' do
      let(:email_address) { 'unknown@example.com' }

      scenario "completing the Journey" do
        complete_personal_information_step
        complete_contact_information_step
        complete_education_step
        complete_teaching_preference_step
        complete_placement_preference_step
        complete_background_step
        complete_application_preview_step button_text: 'Continue'
        complete_email_confirmation_step
        view_request_acknowledgement_step
      end
    end

    context 'for unknown Candidate but Contact is in Gitis' do
      include_context 'fake gitis with known uuid'

      let(:token) { create(:candidate_session_token) }
      let(:fake_data) { fake_gitis.send(:fake_contact_data) }
      let(:email_address) { fake_data['emailaddress2'] }
      let(:name) { fake_data['firstname'] + ' ' + fake_data['lastname'] }
      let(:date_of_birth) { Date.parse fake_data['birthdate'] }

      scenario "completing the Journey" do
        complete_personal_information_step
        complete_sign_in_step(token.token)
        complete_contact_information_step
        complete_education_step
        complete_teaching_preference_step
        complete_placement_preference_step
        complete_background_step
        complete_application_preview_step(name: name, date_of_birth: date_of_birth)
        view_request_acknowledgement_step
      end
    end

    context 'for known Candidate not signed in' do
      include_context 'fake gitis with known uuid'

      let(:fake_data) { fake_gitis.send(:fake_contact_data) }
      let(:email_address) { fake_data['emailaddress2'] }
      let(:name) { fake_data['firstname'] + ' ' + fake_data['lastname'] }
      let(:date_of_birth) { Date.parse fake_data['birthdate'] }
      let!(:candidate) { create(:candidate, :confirmed, gitis_uuid: fake_gitis_uuid) }
      let(:token) { create(:candidate_session_token, candidate: candidate) }

      before do
        allow_any_instance_of(Candidates::Registrations::PersonalInformation).to \
          receive(:create_signin_token).and_return(token.token)
      end

      scenario "completing the Journey" do
        complete_personal_information_step
        complete_sign_in_step(token.token)
        complete_contact_information_step
        complete_education_step
        complete_teaching_preference_step
        complete_placement_preference_step
        complete_background_step
        complete_application_preview_step(name: name, date_of_birth: date_of_birth)
        view_request_acknowledgement_step
      end
    end

    context 'for known Candidate already signed in' do
      include_context 'fake gitis with known uuid'

      # Contact gets default email address after reload via token lookup
      let(:fake_data) { fake_gitis.send(:fake_contact_data) }
      let(:email_address) { fake_data['emailaddress2'] }
      let(:name) { fake_data['firstname'] + ' ' + fake_data['lastname'] }
      let(:date_of_birth) { Date.parse fake_data['birthdate'] }
      let!(:candidate) { create(:candidate, :confirmed, gitis_uuid: fake_gitis_uuid) }
      let(:token) { create(:candidate_session_token, candidate: candidate) }

      before do
        allow_any_instance_of(Candidates::Session).to \
          receive(:create_signin_token).and_return(token.token)
      end

      scenario "completing the Journey" do
        sign_in_via_dashboard(token.token)
        complete_personal_information_step fill_in_fields: false
        complete_contact_information_step
        complete_education_step
        complete_teaching_preference_step
        complete_placement_preference_step
        complete_background_step
        complete_application_preview_step(name: name, date_of_birth: date_of_birth)
        view_request_acknowledgement_step
      end
    end

    context 'for known Candidate already signed in switching account part way through' do
      include_context 'fake gitis with known uuid'

      let(:email_address) { 'test@example.com' }
      let!(:candidate) { create(:candidate, :confirmed, gitis_uuid: fake_gitis_uuid) }
      let(:token) { create(:candidate_session_token, candidate: candidate) }
      let(:newtoken) { create(:candidate_session_token) }

      before do
        allow_any_instance_of(Candidates::Session).to \
          receive(:create_signin_token).and_return(token.token)
      end

      scenario "completing the Journey" do
        sign_in_via_dashboard(token.token)
        complete_personal_information_step(fill_in_fields: false)
        complete_contact_information_step
        sign_in_via_dashboard(newtoken.token)
        swap_back_to_education_step
        get_bounced_to_contact_information_step
      end
    end
  end

  def complete_personal_information_step(expected_heading: nil, fill_in_fields: true)
    # Begin wizard journey
    visit "/candidates/schools/#{school_urn}/registrations/personal_information/new"
    expect(page).to have_text expected_heading || 'Check if we already have your details'

    if fill_in_fields
      # Submit personal information form with errors
      fill_in 'First name', with: 'testy'
      fill_in 'Last name', with: ''
      click_button 'Continue'
      expect(page).to have_text 'There is a problem'

      # Submit personal information form successfully
      fill_in 'First name', with: 'testy'
      fill_in 'Last name', with: 'mctest'
      fill_in 'Email address', with: email_address
      fill_in 'Day', with: '01'
      fill_in 'Month', with: '01'
      fill_in 'Year', with: '2000'
    end

    click_button 'Continue'
  end

  def complete_sign_in_step(token)
    expect(page.current_path).to eq \
      "/candidates/schools/#{school_urn}/registrations/sign_in"
    expect(page).to have_text 'We already have your details'

    # Follow the link from email
    visit "/candidates/verify/#{school_urn}/#{token}"
  end

  def complete_contact_information_step
    expect(page.current_path).to eq \
      "/candidates/schools/#{school_urn}/registrations/contact_information/new"

    # Submit contact information form with errors
    fill_in 'Building', with: ''
    click_button 'Continue'
    expect(page).to have_text 'There is a problem'

    # Submit contact information form successfully
    fill_in 'Building', with: 'Test house'
    fill_in 'Street', with: 'Test street'
    fill_in 'Town or city', with: 'Test Town'
    fill_in 'County', with: 'Testshire'
    fill_in 'Postcode', with: 'TE57 1NG'
    fill_in 'UK telephone number', with: '01234567890'
    click_button 'Continue'
  end

  def complete_education_step
    expect(page.current_path).to eq \
      "/candidates/schools/#{school_urn}/registrations/education/new"

    # Submit registrations/education form with errors
    choose 'Graduate or postgraduate'
    click_button 'Continue'
    expect(page).to have_text "There is a problem"

    # Submit registrations/education form successfully
    choose 'Graduate or postgraduate'
    select 'Physics', from: 'If you have or are studying for a degree, tell us about your degree subject'
    click_button 'Continue'
  end

  def complete_teaching_preference_step
    expect(page.current_path).to eq \
      "/candidates/schools/#{school_urn}/registrations/teaching_preference/new"

    # Submit registrations/teaching_preference form with errors
    choose "I’m very sure and think I’ll apply"
    click_button 'Continue'

    # Submit registrations/teaching_preference form successfully
    choose "I’m very sure and think I’ll apply"
    select 'Physics', from: 'First choice'
    select 'Maths', from: 'Second choice'
    click_button 'Continue'
  end

  def complete_placement_preference_step
    expect(page.current_path).to eq \
      "/candidates/schools/#{school_urn}/registrations/placement_preference/new"

    # Submit registrations/placement_preference form with errors
    fill_in 'What do you want to get out of your school experience?', with: 'I enjoy teaching'
    click_button 'Continue'
    expect(page).to have_text 'There is a problem'

    # Submit registrations/placement_preference form successfully
    fill_in 'Tell us about your availability', with: 'Only free from Epiphany to Whitsunday'
    fill_in 'What do you want to get out of your school experience?', with: 'I enjoy teaching'
    click_button 'Continue'
  end

  def complete_background_step
    expect(page.current_path).to eq \
      "/candidates/schools/#{school_urn}/registrations/background_check/new"

    # Submit registrations/background_check form with errors
    click_button 'Continue'
    expect(page).to have_text 'There is a problem'

    # Submit registrations/background_check form successfully
    choose 'Yes'
    click_button 'Continue'
  end

  def complete_application_preview_step(name: 'testy mctest', email: nil,
    date_of_birth: Date.parse('2000-01-01'), button_text: 'Accept and send')

    expect(page.current_path).to eq \
      "/candidates/schools/#{school_urn}/registrations/application_preview"

    # Expect preview to match the data we successfully submited
    expect(page).to have_text "Full name #{name}"
    expect(page).to have_text \
      'Address Test house, Test street, Test Town, Testshire, TE57 1NG'
    expect(page).to have_text 'UK telephone number 01234567890'
    expect(page).to have_text "Email address #{email || email_address}"
    expect(page).to have_text "Date of birth #{date_of_birth.strftime '%d/%m/%Y'}"
    expect(page).to have_text "School or college #{school.name}"
    expect(page).to have_text 'Experience availability Only free from Epiphany to Whitsunday'
    expect(page).to have_text "What you want to get out of school experience I enjoy teaching"
    expect(page).to have_text "Degree stage Graduate or postgraduate"
    expect(page).to have_text "Degree subject Physics"
    expect(page).to have_text "I’m very sure and think I’ll apply"
    expect(page).to have_text "Teaching subject - first choice Physics"
    expect(page).to have_text "Teaching subject - second choice Maths"
    expect(page).to have_text "DBS certificate Yes"

    # Submit email confirmation form with errors
    click_button button_text
    expect(page).to have_text 'You need to confirm your details are correct and accept our privacy policy to continue'
    expect(page).not_to have_text \
      "We've sent a link to the following email address:\ntest@example.com"

    # Submit email confirmation form successfully
    check "candidates_registrations_privacy_policy_acceptance"
    click_button button_text
  end

  def complete_email_confirmation_step
    expect(page).to have_text \
      "We've sent a link to the following email address:\n#{email_address}"

    # Click email confirmation link
    visit "/candidates/confirm/#{registration_session.uuid}"
  end

  def view_request_acknowledgement_step
    expect(page).to have_text \
      "Your request for school experience will be forwarded to Test School."
  end

  def sign_in_via_dashboard(token)
    visit "/candidates/signin"

    fill_in 'Email address', with: email_address
    fill_in 'First name', with: 'testy'
    fill_in 'Last name', with: 'mctest'
    fill_in 'Day', with: '01'
    fill_in 'Month', with: '01'
    fill_in 'Year', with: '1980'
    click_button 'Sign in'

    visit "/candidates/signin/#{token}"
    expect(page.current_path).to eq "/candidates/dashboard"
  end

  def swap_back_to_education_step
    visit "/candidates/schools/#{school_urn}/registrations/education/new"
  end

  def get_bounced_to_contact_information_step
    visit "/candidates/schools/#{school_urn}/registrations/application_preview"
    expect(page.current_path).to eq \
      "/candidates/schools/#{school_urn}/registrations/contact_information/new"
  end
end
