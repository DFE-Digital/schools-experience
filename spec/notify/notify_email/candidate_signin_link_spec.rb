require 'rails_helper'

describe NotifyEmail::CandidateSigninLink do
  it_should_behave_like "email template", "5b451894-3640-47df-a119-6461ecb890d9",
    confirmation_link: "ABCDEFGHIJKLM1234567890"
end
