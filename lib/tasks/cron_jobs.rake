namespace :db do
  desc 'Schedule all cron jobs'
  task schedule_jobs: :environment do
    glob = Rails.root.join('app', 'jobs', 'cron', '**', '*_job.rb')
    Dir.glob(glob).sort.each { |f| require f }
    CronJob.subclasses.each(&:schedule)
  end
end

# in production only, invoke schedule_jobs automatically after every migration
# and schema load.
if Rails.env.production?
  %w[db:migrate db:schema:load].each do |task|
    Rake::Task[task].enhance do
      Rake::Task['db:schedule_jobs'].invoke
    end
  end
end
