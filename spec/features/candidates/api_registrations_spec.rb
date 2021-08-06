require 'rails_helper'

feature 'Candidate Registrations (via the API)', type: :feature do
  include_context "api teaching subjects"
  include_context "api latest privacy policy"
  include_context "api add classroom experience note"
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
        complete_background_step
        complete_application_preview_step(name: sign_up.full_name, date_of_birth: sign_up.date_of_birth)
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
        complete_background_step
        complete_application_preview_step(name: sign_up.full_name, date_of_birth: sign_up.date_of_birth)
        view_request_acknowledgement_step
      end
    end

    context 'for known Candidate already signed in' do
      include_context "api candidate matched back"
      include_context "api correct verification code"

      let(:email_address) { sign_up.email }
      let!(:candidate) { create(:candidate, :confirmed, gitis_uuid: sign_up.candidate_id) }

      before do
        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:get_schools_experience_sign_up)
            .with(sign_up.candidate_id) { sign_up }
      end

      scenario "completing the Journey" do
        sign_in_via_dashboard(sign_up)
        complete_personal_information_step fill_in_fields: false
        complete_contact_information_step
        complete_education_step
        complete_teaching_preference_step
        complete_placement_preference_step
        complete_background_step
        complete_application_preview_step(name: sign_up.full_name, date_of_birth: sign_up.date_of_birth)
        view_request_acknowledgement_step
      end
    end

    context 'for known Candidate already signed in switching account part way through' do
      include_context "api candidate matched back"
      include_context "api correct verification code"

      let(:email_address) { sign_up.email }
      let(:candidate1) { create(:candidate, :confirmed, gitis_contact: sign_up, gitis_uuid: sign_up.candidate_id) }
      let(:candidate2) { create(:candidate, :confirmed, :with_api_contact) }
      let(:request2) do
        GetIntoTeachingApiClient::ExistingCandidateRequest.new(
          firstName: candidate2.gitis_contact.first_name,
          lastName: candidate2.gitis_contact.last_name,
          email: candidate2.gitis_contact.email,
          dateOfBirth: candidate2.gitis_contact.date_of_birth
        )
      end

      before do
        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:get_schools_experience_sign_up)
            .with(candidate2.gitis_uuid) { candidate2.gitis_contact }
        allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
          receive(:exchange_access_token_for_schools_experience_sign_up)
            .with(code, request2) { candidate2.gitis_contact }
      end

      scenario "completing the Journey" do
        sign_in_via_dashboard(candidate1.gitis_contact)
        complete_personal_information_step(fill_in_fields: false)
        complete_contact_information_step
        sign_in_via_dashboard(candidate2.gitis_contact)
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

  def complete_sign_in_step
    fill_in "Enter your verification code here", with: code
    click_button "Submit"
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
    expect(page).to have_text "Experience availability\nOnly free from Epiphany to Whitsunday"
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
    expect(page).to have_text "You've requested school experience at"
  end

  def sign_in_via_dashboard(sign_up)
    visit "/candidates/signin"

    fill_in 'Email address', with: sign_up.email
    fill_in 'First name', with: sign_up.first_name
    fill_in 'Last name', with: sign_up.last_name
    fill_in 'Day', with: sign_up.date_of_birth.day
    fill_in 'Month', with: sign_up.date_of_birth.month
    fill_in 'Year', with: sign_up.date_of_birth.year
    click_button 'Sign in'

    expect(page.current_path).to eq "/candidates/signin"

    complete_sign_in_step

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
