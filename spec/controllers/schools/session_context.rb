shared_context "logged in DfE user" do
  let(:urn) { 123456 }
  let(:user_guid) { '33333333-4444-5555-6666-777777777777' }
  let(:dfe_signin_school_urn) { 123489 }
  let(:dfe_signin_school_id) { '33333333-aaaa-5555-bbbb-777777777777' }
  let(:dfe_signin_school_data) do
    [
      { urn: dfe_signin_school_urn, name: 'School A', id: dfe_signin_school_id },
      { urn: 123490, name: 'School B', id: '33333333-aaaa-5555-cccc-777777777777' }
    ]
  end

  let(:dfe_signin_role_data) do
    { roles: [{ id: '66666666-5555-4444-3333-222222222222' }] }
  end

  before do
    if Bookings::School.find_by(urn: urn).nil?
      @current_user_school = FactoryBot.create(:bookings_school, urn: urn)
    end

    allow_any_instance_of(ActionDispatch::Request)
      .to(
        receive(:session).and_return(
          current_user: OpenStruct.new(given_name: 'Martin', family_name: 'Prince', sub: user_guid),
          urn: urn
        )
      )

    stub_request(:get, "https://some-signin-host.signin.education.gov.uk/users/#{user_guid}/organisations")
      .to_return(
        status: 200,
        body: dfe_signin_school_data.to_json,
        headers: {}
      )

    stub_request(:get, "https://some-signin-host.signin.education.gov.uk/services/66666666-5555-aaaa-bbbb-cccccccccccc/organisations/33333333-aaaa-5555-bbbb-777777777777/users/33333333-4444-5555-6666-777777777777")
      .to_return(
        status: 200,
        body: dfe_signin_role_data.to_json,
        headers: {}
      )
  end
end

shared_examples "a protected page" do
  let(:protocol) { "https://" }
  let(:host) { Rails.configuration.x.oidc_host }
  let(:auth_path) { "/auth" }
  let(:host_regexp) { %r{\A#{[protocol, host, auth_path].join}} }

  specify "user is re-directed to the provider's OpenIDConnect login page" do
    expect(subject).to redirect_to(host_regexp)
  end
end
