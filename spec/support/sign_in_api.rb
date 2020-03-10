shared_context "enable signin api" do
  let(:enable_signin_api) { true }
  before do
    allow(Schools::DFESignInAPI::Client).to \
      receive(:enabled?) { enable_signin_api }
  end
end

shared_context "stub role check api" do
  include_context "enable signin api"

  let(:role_check_class) { Schools::DFESignInAPI::Roles }

  let(:enable_signin_role_check_api) { true }
  let(:signin_role_check_response) { true }

  before do
    allow(role_check_class).to receive(:enabled?) { enable_signin_role_check_api }

    allow_any_instance_of(role_check_class).to \
      receive(:has_school_experience_role?) { signin_role_check_response }
  end
end
