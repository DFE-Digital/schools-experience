require 'rails_helper'

describe NotifySms::CandidateRequestConfirmationNoPii do
  it_should_behave_like "sms template", "880be18e-fbd4-4427-8b87-59e026626031",
                        school_name: "Springfield Elementary School"
end
