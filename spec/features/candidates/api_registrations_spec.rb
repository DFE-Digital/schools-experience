require 'rails_helper'

feature 'Candidate Registrations (via the API)', type: :feature do
  include_context "api teaching subjects"
  include_context "api latest privacy policy"
  include_context "api add school experience"
  include_context "api sign up"
  include_context "Stubbed candidates school"

  let(:today) { Time.zone.today }
  let(:tomorrow) { today + 1.day }
  let(:uuid) { SecureRandom.urlsafe_base64 }
  let(:registration_session) do
    FactoryBot.build :registration_session, current_time: today, uuid: uuid
  end

  before do
    allow_any_instance_of(Candidates::Registrations::RegistrationSession).to \
      receive(:uuid).and_return(uuid)
  end

  feature 'Candidate Registration' do
    context 'for unknown Contact' do
      include_context "api candidate not matched back"

      let(:email_address) { 'unknown@example.com' }

      scenario "completing the Journey" do
        complete_personal_information_step
        complete_contact_information_step
        complete_education_step
        complete_teaching_preference_step
        complete_placement_preference_step
        complete_availability_preference_step
        complete_background_step
        complete_application_preview_step button_text: 'Continue'
        complete_email_confirmation_step
        view_request_acknowledgement_step
      end
    end

    context 'for unknown Candidate but Contact is in Gitis' do
      include_context "api candidate matched back"
      include_context "api correct verification code"

      let(:email_address) { sign_up.email }

      scenario "completing the Journey" do
        complete_personal_information_step
        complete_sign_in_step
        complete_contact_information_step
        complete_education_step
        complete_teaching_preference_step
        complete_placement_preference_step
        complete_availability_preference_step
        complete_background_step
        complete_application_preview_step(name: sign_up.full_name)
        view_request_acknowledgement_step
      end
    end

    context 'for known Candidate not signed in' do
      include_context "api candidate matched back"
      include_context "api correct verification code"

      let(:email_address) { sign_up.email }
      let!(:candidate) { create(:candidate, :confirmed, gitis_uuid: sign_up.candidate_id) }

      scenario "completing the Journey" do
        complete_personal_information_step
        complete_sign_in_step
        complete_contact_information_step
        complete_education_step
        complete_teaching_preference_step
        complete_placement_preference_step
        complete_availability_preference_step
        complete_background_step
        complete_application_preview_step(name: sign_up.full_name,)
        view_request_acknowledgement_step
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
    end

    click_button 'Continue'
  end

  def complete_sign_in_step
    fill_in "Enter your verification code here", with: code
    click_button "Submit"
  end

  def complete_contact_information_step
    expect(page).to have_current_path \
      "/candidates/schools/#{school_urn}/registrations/contact_information/new", ignore_query: true

    # Submit contact information form with errors
    fill_in 'Address line 1', with: ''
    click_button 'Continue'
    expect(page).to have_text 'There is a problem'

    # Submit contact information form successfully
    fill_in 'Address line 1', with: 'Test house'
    fill_in 'Address line 2 (optional)', with: 'Test street'
    fill_in 'Town or city (optional)', with: 'Test Town'
    fill_in 'County (optional)', with: 'Testshire'
    fill_in 'Postcode', with: 'TE57 1NG'
    fill_in 'UK telephone number', with: '01234567890'
    click_button 'Continue'
  end

  def complete_education_step
    expect(page).to have_current_path \
      "/candidates/schools/#{school_urn}/registrations/education/new", ignore_query: true

    # Submit registrations/education form with errors
    choose 'Graduate or postgraduate'
    click_button 'Continue'
    expect(page).to have_text "There is a problem"

    # Submit registrations/education form successfully
    choose 'Graduate or postgraduate'
    fill_in "What subject are you studying?", with: "Physics"
    click_button 'Continue'
  end

  def complete_teaching_preference_step
    expect(page).to have_current_path \
      "/candidates/schools/#{school_urn}/registrations/teaching_preference/new", ignore_query: true

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
    expect(page).to have_current_path \
      "/candidates/schools/#{school_urn}/registrations/placement_preference/new", ignore_query: true

    # Submit registrations/placement_preference form with errors
    fill_in 'Enter what you want to get out of your placement', with: ''
    click_button 'Continue'
    expect(page).to have_text 'There is a problem'

    # Submit registrations/placement_preference form successfully
    fill_in 'Enter what you want to get out of your placement', with: 'I enjoy teaching'
    click_button 'Continue'
  end

  def complete_availability_preference_step
    expect(page).to have_current_path \
      "/candidates/schools/#{school_urn}/registrations/availability_preference/new", ignore_query: true

    # Submit registrations/availability_preference form with errors
    fill_in 'Enter your availability', with: ''
    click_button 'Continue'
    expect(page).to have_text 'There is a problem'

    # Submit registrations/availability_preference form successfully
    fill_in 'Enter your availability', with: 'Only free from Epiphany to Whitsunday'
    click_button 'Continue'
  end

  def complete_background_step
    expect(page).to have_current_path \
      "/candidates/schools/#{school_urn}/registrations/background_check/new", ignore_query: true

    # Submit registrations/background_check form with errors
    click_button 'Continue'
    expect(page).to have_text 'There is a problem'

    # Submit registrations/background_check form successfully
    choose 'Yes'
    click_button 'Continue'
  end

  def complete_application_preview_step(name: 'testy mctest', email: nil, button_text: 'Accept and send')
    expect(page).to have_current_path \
      "/candidates/schools/#{school_urn}/registrations/application_preview", ignore_query: true

    # Expect preview to match the data we successfully submited
    expect(page).to have_text "Full name #{name}"
    expect(page).to have_text \
      'Address Test house, Test street, Test Town, Testshire, TE57 1NG'
    expect(page).to have_text 'UK telephone number 01234567890'
    expect(page).to have_text "Email address #{email || email_address}"
    expect(page).to have_text "School or college #{school.name}"
    expect(page).to have_text "Experience availability\nOnly free from Epiphany to Whitsunday"
    expect(page).to have_text "What you want to get out of school experience I enjoy teaching"
    expect(page).to have_text "Degree stage Graduate or postgraduate"
    expect(page).to have_text "Degree subject Physics"
    expect(page).to have_text "I’m very sure and think I’ll apply"
    expect(page).to have_text "Teaching subject - first choice Physics"
    expect(page).to have_text "Teaching subject - second choice Maths"
    expect(page).to have_text "DBS certificate Yes"

    # Submit email confirmation form successfully
    click_button button_text
    # Check they see a success message (changes for new/existing users)
    new_user_success = /We've sent a link to the following email address/
    existing_user_success = /What happens next/
    expect(page.text).to match %r{(#{new_user_success})|(#{existing_user_success})}
  end

  def complete_email_confirmation_step
    expect(page).to have_text \
      "We've sent a link to the following email address:\n#{email_address}"

    # Click email confirmation link
    visit "/candidates/confirm/#{registration_session.uuid}"
  end

  def view_request_acknowledgement_step
    expect(page).to have_text "You've requested school experience at"
  end

  def visit_candidate_dashboard_step
    click_button 'Visit your dashboard'
    expect(page).to have_text "Your dashboard"
  end

  def swap_back_to_education_step
    visit "/candidates/schools/#{school_urn}/registrations/education/new"
  end

  def get_bounced_to_contact_information_step
    visit "/candidates/schools/#{school_urn}/registrations/application_preview"
    expect(page).to have_current_path \
      "/candidates/schools/#{school_urn}/registrations/contact_information/new", ignore_query: true
  end
end
