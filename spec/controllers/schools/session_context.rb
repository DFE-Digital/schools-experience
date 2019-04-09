shared_context "logged in DfE user" do
  let(:urn) { 123456 }

  before do
    if Bookings::School.find_by(urn: urn).nil?
      @current_user_school = FactoryBot.create(:bookings_school, urn: urn)
    end

    allow_any_instance_of(ActionDispatch::Request)
      .to(
        receive(:session).and_return(
          current_user: { name: "joey" },
          urn: urn
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
