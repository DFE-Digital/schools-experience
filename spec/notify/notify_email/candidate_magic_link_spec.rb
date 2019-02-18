require 'rails_helper'

describe NotifyEmail::CandidateMagicLink do
  it_should_behave_like "email template", "74dc6510-c89d-4b5b-9608-075d3f2de32d",
    school_name: "Springfield Elementary School",
    confirmation_link: "ABCDEFGHIJKLM1234567890"
end
