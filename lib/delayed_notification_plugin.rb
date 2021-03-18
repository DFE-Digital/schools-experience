class DelayedNotificationPlugin < Delayed::Plugin
  callbacks do |lifecycle|
    lifecycle.before(:failure) do |_worker, job, *_args, &_block|
      ExceptionNotifier.notify_exception(job.error,
        data: job.attributes.except('last_error'))
    end
  end
end
