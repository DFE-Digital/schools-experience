def path_for(descriptor, school: nil, placement_date_id: nil, booking_id: nil, placement_request_id: nil)
  if school && school.respond_to?(:to_param)
    school = school.to_param
  end

  mappings = {
    # candidate paths
    "landing" => [:root_path],
    "splash" => [:candidates_splash_path],
    "find a school" => [:new_candidates_school_search_path],
    "request school experience placement" => [:new_candidates_school_registrations_placement_preference_path, school],
    "enter your contact details" => [:new_candidates_school_registrations_contact_information_path, school],
    "candidate subjects" => [:new_candidates_school_registrations_subject_preference_path, school],
    "background checks" => [:new_candidates_school_registrations_background_check_path, school],
    "check your answers" => [:candidates_school_registrations_application_preview_path, school],

    #school paths
    "schools" => [:schools_root_path],
    "schools dashboard" => [:schools_dashboard_path],
    "bookings" => [:schools_bookings_path],
    "upcoming bookings" => [:schools_upcoming_bookings_path],
    "booking" => [:schools_booking_path, booking_id],
    "placement requests" => [:schools_placement_requests_path],
    "upcoming requests" => [:schools_upcoming_requests_path],
    "placement request" => [:schools_placement_request_path, placement_request_id],
    "confirm booking" => [:new_schools_placement_request_acceptance_confirm_booking_path, placement_request_id],
    "add more details" => [:new_schools_placement_request_acceptance_add_more_details_path, placement_request_id],
    "review and send email" => [:new_schools_placement_request_acceptance_review_and_send_email_path, placement_request_id],
    "reject placement request" => [:new_schools_placement_request_reject_path, placement_request_id],
    "candidate requirements" => [:new_schools_on_boarding_candidate_requirement_path],
    "fees charged" => [:new_schools_on_boarding_fees_path],
    "administration costs" => [:new_schools_on_boarding_administration_fee_path],
    "other costs" => [:new_schools_on_boarding_other_fee_path],
    "dbs check costs" => [:new_schools_on_boarding_dbs_fee_path],
    "phases" => [:new_schools_on_boarding_phases_list_path],
    "primary subjects list" => [:new_schools_on_boarding_key_stage_list_path],
    "subjects" => [:new_schools_on_boarding_subjects_path],
    "description" => [:new_schools_on_boarding_description_path],
    "candidate experience details" => [:new_schools_on_boarding_candidate_experience_detail_path],
    "availability" => [:new_schools_on_boarding_availability_path],
    "availability preferences" => [:edit_schools_availability_preference_path],
    "availability information" => [:edit_schools_availability_info_path],
    "placement dates" => [:schools_placement_dates_path],
    "new placement date" => [:new_schools_placement_date_path],
    "edit placement date" => [:edit_schools_placement_date_path, placement_date_id],
    "experience outline" => [:new_schools_on_boarding_experience_outline_path],
    "admin contact" => [:new_schools_on_boarding_admin_contact_path],
    "profile" => [:schools_on_boarding_profile_path],
    "toggle requests" => [:edit_schools_enabled_path],
    "not registered error" => [:schools_errors_not_registered_path],
    "change school" => [:new_schools_switch_path]
  }

  (path = mappings[descriptor.downcase]) ? send(*path) : fail("No mapping for #{descriptor}")
end
