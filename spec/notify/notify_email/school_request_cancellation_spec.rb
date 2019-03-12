require 'rails_helper'

describe NotifyEmail::SchoolRequestCancellation do
  it_should_behave_like "email template", "1d2b44bc-9d73-4839-b06b-41f35012c14d",
    school_admin_name: "Seymour Skinner",
    school_name: "Springfield Elementary School",
    candidate_name: "Otto Mann",
    placement_start_date: "2022-04-01",
    placement_finish_date: "2022-04-20"
end
