require "rails_helper"

# Exercises the real session middleware and cookie through an endpoint that
# keeps a return link in the session.
describe "Database backed sessions", type: :request do
  let(:cookie_name) { Rails.application.config.session_options[:key] }
  let(:referer) { "http://www.example.com/dfe_signin_help" }

  def start_session
    get edit_cookie_preference_path, headers: { "HTTP_REFERER" => referer }
    cookies[cookie_name]
  end

  it "stores the session in the database, not in the cookie" do
    public_id = start_session

    row = BrowserSession.sole
    expect(row.session_id).to eq "2::#{Digest::SHA256.hexdigest(public_id)}"
    expect(row.payload).to include("cookie_preference_referer" => referer)
    expect(row.expires_at).to be_within(1.minute).of(1.hour.from_now)
  end

  it "resumes the session on the next request" do
    public_id = start_session
    first_row_id = BrowserSession.sole.session_id
    put cookie_preference_path, params: { cookie_preference: { analytics: "yes" } }

    expect(BrowserSession.sole.session_id).to eq first_row_id
    expect(cookies[cookie_name]).to eq public_id
    expect(BrowserSession.sole.payload).to include("flash")
  end

  it "ignores a tampered or unknown cookie" do
    start_session
    cookies[cookie_name] = "tampered"
    put cookie_preference_path, params: { cookie_preference: { analytics: "yes" } }

    expect(response).not_to redirect_to referer
    expect(cookies[cookie_name]).not_to eq "tampered"
  end

  it "ignores an expired session without waiting for cleanup" do
    start_session
    BrowserSession.update_all expires_at: 1.minute.ago
    put cookie_preference_path, params: { cookie_preference: { analytics: "yes" } }

    expect(response).not_to redirect_to referer
  end

  it "ignores a deleted session" do
    start_session
    BrowserSession.delete_all
    put cookie_preference_path, params: { cookie_preference: { analytics: "yes" } }

    expect(response).not_to redirect_to referer
  end

  it "carries over a session created before the move from the cache" do
    cookies[cookie_name] = "legacycookievalue"
    private_id = "2::#{Digest::SHA256.hexdigest('legacycookievalue')}"
    Rails.cache.write "_session_id:#{private_id}", { "marker" => "legacy" }, expires_in: 1.hour

    put cookie_preference_path, params: { cookie_preference: { analytics: "yes" } }

    expect(BrowserSession.sole.payload).to include("marker" => "legacy")
    expect(Rails.cache.exist?("_session_id:#{private_id}")).to be false
  end
end
