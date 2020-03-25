# Subjects
YAML.load_file(Rails.root.join('db', 'data', 'subjects.yml')).each do |name|
  Bookings::Subject.create(name: name, secondary_subject: name != 'Primary')
end

# Phases
YAML.load_file(Rails.root.join('db', 'data', 'phases.yml')).each do |edubase_id, name|
  Bookings::Phase.create(name: name, edubase_id: edubase_id)
end

# School types
YAML.load_file(Rails.root.join('db', 'data', 'school_types.yml')).each do |edubase_id, name|
  Bookings::SchoolType.create(name: name, edubase_id: edubase_id)
end

puts "\nYou can import all 47000 schools using 'bundle exec rails data:schools:mass_import'"
