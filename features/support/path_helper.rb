def path_for(descriptor, school: nil)
  if school && school.respond_to?(:to_param)
    school = school.to_param
  end

  mappings = {
    "landing" => [:root_path],
    "find a school" => [:candidates_schools_path],
    "request school experience placement" => [:new_candidates_school_registrations_placement_preference_path, school],
    "enter your contact details" => [:new_candidates_school_registrations_contact_information_path, school],
    "candidate subjects" => [:new_candidates_school_registrations_subject_preference_path, school],
    "background checks" => [:new_candidates_school_registrations_background_check_path, school],
    "check your answers" => [:candidates_school_registrations_application_preview_path, school]
  }

  (path = mappings[descriptor.downcase]) ? send(*path) : fail("No mapping for #{descriptor}")
end
