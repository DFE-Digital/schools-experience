require 'rails_helper'

describe NotifyEmail::CandidateVerifyEmailLink do
  it_should_behave_like "email template", "0e4b2eaa-ae1f-472a-9293-c2a24f3f8187",
    verification_link: "ABCDEFGHIJKLM1234567890"
end
