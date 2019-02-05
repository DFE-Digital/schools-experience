def path_for(descriptor)
  mappings = {
    "landing" => root_path,
    "find a school" => candidates_schools_path
  }

  (path = mappings[descriptor.downcase]) ? path : fail("No mapping for #{descriptor}")
end
