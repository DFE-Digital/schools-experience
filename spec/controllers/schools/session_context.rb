shared_context "logged in DfE user" do
  before do
    allow_any_instance_of(ActionDispatch::Request)
      .to(
        receive(:session).and_return(
          current_user: { name: "joey" },
          urn: 356127
        )
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
