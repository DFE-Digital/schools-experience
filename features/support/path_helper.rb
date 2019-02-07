def path_for(descriptor)
  mappings = {
    "landing" => root_path,
    "find a school" => candidates_schools_path,
    "request school experience placement" => new_candidates_registrations_placement_preference_path,
    "check if we already have your details" => new_candidates_registrations_account_check_path,
    "candidate address" => new_candidates_registrations_address_path,
    "candidate subjects" => new_candidates_registrations_subject_preference_path,
    "background checks" => new_candidates_registrations_background_check_path,
    "check your answers" => candidates_registrations_application_preview_path
  }

  (path = mappings[descriptor.downcase]) ? path : fail("No mapping for #{descriptor}")
end
