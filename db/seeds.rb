# Subjects
YAML.load_file(File.join(Rails.root, 'db', 'data', 'subjects.yml')).each do |name|
  Bookings::Subject.create(name: name, secondary_subject: name != 'Primary')
end

# Phases
YAML.load_file(File.join(Rails.root, 'db', 'data', 'phases.yml')).each do |edubase_id, name|
  Bookings::Phase.create(name: name, edubase_id: edubase_id)
end

# Phases
YAML.load_file(File.join(Rails.root, 'db', 'data', 'school_types.yml')).each do |edubase_id, name|
  Bookings::SchoolType.create(name: name, edubase_id: edubase_id)
end
