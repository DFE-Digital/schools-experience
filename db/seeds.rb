# Subjects
YAML.load_file(File.join(Rails.root, 'db', 'data', 'subjects.yml')).each do |name|
end

# Phases
YAML.load_file(File.join(Rails.root, 'db', 'data', 'phases.yml')).each do |id, name|
  # Force the 'Not applicable' pk to be zero soit matches the EduBase value,
  # allow auto number to assign the rest (they are in order so should match and
  # keep the sequence in sync)
  if id.zero?
    Bookings::Phase.create(id: id, name: name)
  else
    Bookings::Phase.create(name: name)
  end
end
