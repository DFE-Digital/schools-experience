# Subjects
YAML.load_file(File.join(Rails.root, 'db', 'data', 'subjects.yml')).each do |name|
end

# Phases
YAML.load_file(File.join(Rails.root, 'db', 'data', 'phases.yml')).each do |edubase_id, name|
  Bookings::Phase.create(name: name, edubase_id: edubase_id)
end
