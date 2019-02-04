# Subjects
YAML.load_file(File.join(Rails.root, 'db', 'data', 'subjects.yml')).each do |name|
  Bookings::Subject.create(name: name)
end
