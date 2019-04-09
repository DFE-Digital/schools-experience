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
    "upcoming requests" => [:schools_upcoming_index_path],
    "placement request" => [:schools_placement_request_path, 'abc123'],
    "accept placement request" => [:schools_placement_request_accept_path, 'abc123'],
    "reject placement request" => [:schools_placement_request_reject_path, 'abc123'],
  }

  (path = mappings[descriptor.downcase]) ? send(*path) : fail("No mapping for #{descriptor}")
end
