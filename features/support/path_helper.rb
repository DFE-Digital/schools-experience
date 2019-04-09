def path_for(descriptor, school: nil)
  if school && school.respond_to?(:to_param)
    school = school.to_param
  end

  mappings = {
    "landing" => [:root_path],
    "splash" => [:candidates_splash_path],
    "find a school" => [:new_candidates_school_search_path],
    "request school experience placement" => [:new_candidates_school_registrations_placement_preference_path, school],
    "enter your contact details" => [:new_candidates_school_registrations_contact_information_path, school],
    "candidate subjects" => [:new_candidates_school_registrations_subject_preference_path, school],
    "background checks" => [:new_candidates_school_registrations_background_check_path, school],
    "check your answers" => [:candidates_school_registrations_application_preview_path, school],
    "schools dashboard" => [:schools_dashboard_path],
    "placement requests" => [:schools_placement_requests_path],
    "upcoming requests" => [:schools_upcoming_requests_path],
    "placement request" => [:schools_placement_request_path, 'abc123'],
    "accept placement request" => [:schools_placement_request_accept_path, 'abc123'],
    "reject placement request" => [:schools_placement_request_reject_path, 'abc123'],
    "candidate requirements" => [:new_schools_on_boarding_candidate_requirement_path],
    "fees charged" => [:new_schools_on_boarding_fees_path],
    "administration costs" => [:new_schools_on_boarding_administration_fee_path],
    "other costs" => [:new_schools_on_boarding_other_fee_path],
    "dbs check costs" => [:new_schools_on_boarding_dbs_fee_path],
    "phases" => [:new_schools_on_boarding_phases_list_path],
    "primary subjects list" => [:new_schools_on_boarding_key_stage_list_path],
    "secondary subjects" => [:new_schools_on_boarding_secondary_subjects_path],
    "college subjects" => [:new_schools_on_boarding_college_subjects_path],
    "specialisms" => [:new_schools_on_boarding_specialism_path],
    "candidate experience details" => [:new_schools_on_boarding_candidate_experience_detail_path],
    "availability" => [:new_schools_on_boarding_availability_path],
    "experience outline" => [:new_schools_on_boarding_experience_outline_path],
    "admin contact" => [:new_schools_on_boarding_admin_contact_path],
    "profile" => [:schools_on_boarding_profile_path]
  }

  (path = mappings[descriptor.downcase]) ? send(*path) : fail("No mapping for #{descriptor}")
end
