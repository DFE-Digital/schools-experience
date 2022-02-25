require Rails.root.join("lib", "extensions", "yabeda", "delayed_job")

Yabeda::DelayedJob.include(Extensions::Yabeda::DelayedJob)
