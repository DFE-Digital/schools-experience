require 'rails_helper'

describe NotifyEmail::CandidateMagicLink do
  it_should_behave_like "email template", "a06fe38a-5f7f-4c68-8612-6aae9495a8ab",
    school_name: "Springfield Elementary School",
    confirmation_link: "ABCDEFGHIJKLM1234567890"
end
