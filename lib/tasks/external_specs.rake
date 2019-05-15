if Object.const_defined?('RSpec')
  namespace :spec do
    desc "Run API Specs against external APIs, both read and write"
    RSpec::Core::RakeTask.new(external: "spec:prepare") do |t|
      t.pattern = "./spec_external/*_spec.rb"
    end

    namespace :external do
      desc "Run API Specs against external APIs, only read"
      RSpec::Core::RakeTask.new(read: "spec:prepare") do |t|
        t.pattern = "./spec_external/*_spec.rb"
        t.rspec_opts = "--tag=read"
      end

      desc "Run API Specs against external APIs, only write"
      RSpec::Core::RakeTask.new(write: "spec:prepare") do |t|
        t.pattern = "./spec_external/*_spec.rb"
        t.rspec_opts = "--tag=write"
      end
    end
  end
end
