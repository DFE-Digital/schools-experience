def path_for(descriptor, school_id: nil)
  mappings = {
    "landing" => [:root_path],
    "find a school" => [:candidates_schools_path],
    "request school experience placement" => [:new_candidates_school_registrations_placement_preference_path, school_id],
    "check if we already have your details" => [:new_candidates_school_registrations_account_check_path, school_id],
    "candidate address" => [:new_candidates_school_registrations_address_path, school_id],
    "candidate subjects" => [:new_candidates_school_registrations_subject_preference_path, school_id],
    "background checks" => [:new_candidates_school_registrations_background_check_path, school_id],
    "check your answers" => [:candidates_school_registrations_application_preview_path, school_id]
  }

  (path = mappings[descriptor.downcase]) ? send(*path) : fail("No mapping for #{descriptor}")
end
