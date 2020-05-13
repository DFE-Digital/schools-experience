module DFESignInAPI
  # note, the user id guid is defined in lib/servertest/sessions_controller
  def stub_dfe_sign_in_organisations
    stub_request(:get, "https://some-signin-host.signin.education.gov.uk/users/33333333-4444-5555-6666-777777777777/organisations")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => /.*/,
          'Authorization' => /bearer .*/,
          'Content-Type' => 'application/json',
          'User-Agent' => /.*/
        }
      ).to_return(
        status: 200,
        body: [
          { urn: 123455 },
          { urn: 123456 }
        ].to_json,
        headers: {}
      )
  end
end
