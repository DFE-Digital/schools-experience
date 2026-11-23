# Runs an example under a given SESSION_STORAGE phase: `storage_phase: "dual"`
RSpec.configure do |config|
  config.around(:each, :storage_phase) do |example|
    original = Rails.configuration.x.session_storage
    Rails.configuration.x.session_storage = example.metadata[:storage_phase]
    example.run
  ensure
    Rails.configuration.x.session_storage = original
  end
end
