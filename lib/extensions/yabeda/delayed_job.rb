module Extensions
  module Yabeda
    module DelayedJob
      class << self
        def labelize(job)
          result = ::Yabeda::DelayedJob.labelize(job)
          # Prevents PII leaking into metrics labels.
          result[:worker] = job.class.name
          result
        end
      end
    end
  end
end
