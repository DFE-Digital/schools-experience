Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 1
Delayed::Worker.queue_attributes = {
  # Lower number has priority.
  default: { priority: 0 },
  analytics: { priority: 1 }
}
