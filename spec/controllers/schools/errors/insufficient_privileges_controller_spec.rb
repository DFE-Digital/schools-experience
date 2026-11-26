require 'rails_helper'
require_relative '../session_context'

describe Schools::Errors::InsufficientPrivilegesController, type: :request do
  subject { get(schools_errors_inaccessible_school_path) && response }

  include_context "logged in DfE user"


  describe "#show" do
    it { is_expected.to have_http_status :success }
    it { expect(subject.body).to match "Request organisation access" }
    it { expect(subject.body).not_to match "Request service access" }
  end
end
