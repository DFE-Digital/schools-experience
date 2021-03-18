require 'delayed_notification_plugin'

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.sleep_delay = 15
Delayed::Worker.max_attempts = 1
Delayed::Worker.plugins << DelayedNotificationPlugin
