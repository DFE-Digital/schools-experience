def path_for(descriptor, school: nil, placement_date_id: nil, booking_id: nil,
  placement_request: nil, session_token: nil, uuid: nil)

  if school && school.respond_to?(:to_param)
    school = school.to_param
  end

  session_token = session_token&.to_param

  mappings = {
    # candidate paths
    "landing" => [:root_path],
    "splash" => [:candidates_splash_path],
    "find a school" => [:new_candidates_school_search_path],
    "enter your personal details" => [:new_candidates_school_registrations_personal_information_path, school],
    "choose a subject and date" => [:new_candidates_school_registrations_subject_and_date_information_path, school],
    "verify your email" => [:candidates_school_registrations_sign_in_path, school],
    "verify your email with token" => [:candidates_registration_verify_path, school, session_token, uuid],
    "enter your contact details" => [:new_candidates_school_registrations_contact_information_path, school],
    "education" => [:new_candidates_school_registrations_education_path, school],
    "teaching preference" => [:new_candidates_school_registrations_teaching_preference_path, school],
    "edit education" => [:edit_candidates_school_registrations_education_path, school],
    "edit teaching preference" => [:edit_candidates_school_registrations_teaching_preference_path, school],
    "request school experience placement" => [:new_candidates_school_registrations_placement_preference_path, school],
    "background checks" => [:new_candidates_school_registrations_background_check_path, school],
    "check your answers" => [:candidates_school_registrations_application_preview_path, school],
    "cancel placement request" => [:new_candidates_placement_request_cancellation_path, placement_request&.token],
    "candidates_dashboard" => [:candidates_dashboard_path],
    "candidates signin" => [:candidates_signin_path],
    "candidates signin confirm" => [:candidates_signin_confirmation_path, session_token],
    "new candidates feedback" => [:new_candidates_feedback_path],
    "candidate school" => [:candidates_school_path, school],

    #school paths
    "schools" => [:schools_path],
    "contact us" => [:schools_contact_us_path],
    "schools dashboard" => [:schools_dashboard_path],
    "bookings" => [:schools_bookings_path],
    "upcoming bookings" => [:schools_upcoming_bookings_path],
    "previous bookings" => [:schools_previous_bookings_path],
    "booking" => [:schools_booking_path, booking_id],
    "previous booking" => [:schools_previous_booking_path, booking_id],
    "change booking date" => [:edit_schools_booking_date_path, booking_id],
    "booking date changed" => [:schools_booking_date_path, booking_id],
    "placement requests" => [:schools_placement_requests_path],
    "withdrawn requests" => [:schools_withdrawn_requests_path],
    "rejected requests" => [:schools_rejected_requests_path],
    "cancel booking" => [:new_schools_booking_cancellation_path, booking_id],
    "upcoming requests" => [:schools_upcoming_requests_path],
    "placement request" => [:schools_placement_request_path, placement_request],
    "withdrawn request" => [:schools_withdrawn_request_path, placement_request],
    "rejected request" => [:schools_rejected_request_path, placement_request],
    "confirm booking" => [:new_schools_placement_request_acceptance_confirm_booking_path, placement_request],
    "make changes" => [:new_schools_placement_request_acceptance_make_changes_path, placement_request],
    "preview confirmation email" => [:edit_schools_placement_request_acceptance_preview_confirmation_email_path, placement_request],
    "email sent" => [:schools_placement_request_acceptance_email_sent_path, placement_request],
    "reject placement request" => [:new_schools_placement_request_cancellation_path, placement_request&.id],
    "dbs requirements" => [:new_schools_on_boarding_dbs_requirement_path],
    "edit dbs requirements" => [:edit_schools_on_boarding_dbs_requirement_path, school],
    "candidate requirements choice" => [:new_schools_on_boarding_candidate_requirements_choice_path],
    "edit candidate requirements choice" => [:edit_schools_on_boarding_candidate_requirements_choice_path],
    "candidate requirements selection" => [:new_schools_on_boarding_candidate_requirements_selection_path],
    "fees charged" => [:new_schools_on_boarding_fees_path],
    "administration costs" => [:new_schools_on_boarding_administration_fee_path],
    "other costs" => [:new_schools_on_boarding_other_fee_path],
    "dbs check costs" => [:new_schools_on_boarding_dbs_fee_path],
    "phases" => [:new_schools_on_boarding_phases_list_path],
    "primary subjects list" => [:new_schools_on_boarding_key_stage_list_path],
    "subjects" => [:new_schools_on_boarding_subjects_path],
    "description" => [:new_schools_on_boarding_description_path],
    "candidate experience details" => [:new_schools_on_boarding_candidate_experience_detail_path],
    "access needs support" => [:new_schools_on_boarding_access_needs_support_path],
    "access needs detail" => [:new_schools_on_boarding_access_needs_detail_path],
    "disability confident" => [:new_schools_on_boarding_disability_confident_path],
    "access needs policy" => [:new_schools_on_boarding_access_needs_policy_path],
    "availability" => [:new_schools_on_boarding_availability_path],
    "availability preferences" => [:edit_schools_availability_preference_path],
    "availability information" => [:edit_schools_availability_info_path],
    "placement dates" => [:schools_placement_dates_path],
    "new placement date" => [:new_schools_placement_date_path],
    "edit placement date" => [:edit_schools_placement_date_path, placement_date_id],
    "new configuration" => [:new_schools_placement_date_configuration_path, placement_date_id],
    "new subject selection" => [:new_schools_placement_date_subject_selection_path, placement_date_id],
    "experience outline" => [:new_schools_on_boarding_experience_outline_path],
    "admin contact" => [:new_schools_on_boarding_admin_contact_path],
    "profile" => [:schools_on_boarding_profile_path],
    "toggle requests" => [:edit_schools_enabled_path],
    "not registered error" => [:schools_errors_not_registered_path],
    "change school" => [:new_schools_switch_path],
    "confirm attendance" => [:schools_confirm_attendance_path],
    "new schools feedback" => [:new_schools_feedback_path],
    "service updates" => [:service_updates_path],
    "school chooser" => [:schools_change_path]
  }

  (path = mappings[descriptor.downcase]) ? send(*path) : fail("No mapping for #{descriptor}")
end
