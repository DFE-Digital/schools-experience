module Candidates
  module Registrations
    module Behaviours
      module BackgroundCheck
        extend ActiveSupport::Concern

        included do
          validates :has_dbs_check, inclusion: [true, false]
        end
      end
    end
  end
end
