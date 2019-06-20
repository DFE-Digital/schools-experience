require 'rails_helper'
require_relative 'session_context'

describe Schools::ToggleEnabledController, type: :request do
  include_context "restricted unless school onboarded"
end
