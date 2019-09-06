require 'rails_helper'

describe NotifyEmail::SchoolRequestConfirmationLinkOnly do
  it_should_behave_like "email template", "2a5a54b8-17cb-4da8-94ce-1647d6bf1da3",
    school_name: "First School",
    placement_request_url: "https://schoolexperience.education.gov.uk/test/request"
end
