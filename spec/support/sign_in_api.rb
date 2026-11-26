shared_context "when the sign-in API is enabled" do
  let(:enable_signin_api) { true }
  before do
    allow(Schools::DFESignInAPI::Client).to \
      receive(:enabled?) { enable_signin_api }
  end
end

shared_context "when stubbing the role-check API" do
  include_context "when the sign-in API is enabled"

  let(:role_check_class) { Schools::DFESignInAPI::Roles }

  let(:enable_signin_role_check_api) { true }
  let(:signin_role_check_response) { true }

  before do
    allow(Schools::DFESignInAPI::Client).to \
      receive(:role_check_enabled?) { enable_signin_role_check_api }

    role_check = instance_double(
      role_check_class,
      has_school_experience_role?: signin_role_check_response
    )
    allow(role_check_class).to receive(:new).and_return(role_check)
  end
end
