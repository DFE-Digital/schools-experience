def path_for(descriptor)
  mappings = {
    "landing" => root_path,
    "find a school" => candidates_schools_path,
    "request school experience placement" => new_candidates_registrations_placement_preference_path,
    "check if we already have your details" => new_candidates_registrations_account_check_path
  }

  (path = mappings[descriptor.downcase]) ? path : fail("No mapping for #{descriptor}")
end
