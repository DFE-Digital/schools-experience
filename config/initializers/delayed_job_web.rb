dj_enabled = %w[yes true 1].include?(ENV['DELAYED_JOB_ADMIN_ENABLED'])
dj_username = ENV['DELAYED_JOB_ADMIN_USERNAME']
dj_password = ENV['DELAYED_JOB_ADMIN_PASSWORD']

if dj_enabled && dj_username.present? && dj_password.present?
  Rails.application.configure do
    config.x.delayed_job_admin_enabled = true
  end

  DelayedJobWeb.use(Rack::Auth::Basic) do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(dj_username, username) &&
      ActiveSupport::SecurityUtils.secure_compare(dj_password, password)
  end
else
  Rails.application.configure do
    config.x.delayed_job_admin_enabled = false
  end
end
