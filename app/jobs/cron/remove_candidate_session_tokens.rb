module Cron
  class RemoveCandidateSessionTokens < CronJob
    self.cron_expression = '30 1 * * *'

    def perform
      Candidates::SessionToken.remove_old!
    end
  end
end
