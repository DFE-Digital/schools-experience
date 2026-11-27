require "rails_helper"

# Exercises the real session middleware and cookie through an endpoint that
# keeps a return link in the session.
describe "Database backed sessions", type: :request do
  let(:cookie_name) { Rails.application.config.session_options[:key] }
  let(:referer) { "http://www.example.com/dfe_signin_help" }
  let(:save_preference) { -> { put cookie_preference_path, params: { cookie_preference: { analytics: "yes" } } } }

  def start_session
    get edit_cookie_preference_path, headers: { "HTTP_REFERER" => referer }
    cookies[cookie_name]
  end

  def private_id(public_id)
    "2::#{Digest::SHA256.hexdigest(public_id)}"
  end

  def signed(public_id)
    jar = ActionDispatch::TestRequest.create.cookie_jar
    jar.signed[cookie_name] = public_id
    jar[cookie_name]
  end

  def verified(raw)
    ActionDispatch::TestRequest.create("HTTP_COOKIE" => "#{cookie_name}=#{CGI.escape(raw)}").cookie_jar.signed[cookie_name]
  end

  # The id in the cookie after a request: unchanged when the session resumed,
  # replaced when it was rejected
  def current_public_id
    raw = cookies[cookie_name]
    verified(raw) || raw
  end

  def legacy_row(public_id, signed_cookie: false)
    BrowserSession.create!(
      session_id: private_id(public_id),
      session_data: { "cookie_preference_referer" => referer },
      signed_cookie: signed_cookie,
      expires_at: 1.hour.from_now
    )
  end

  it "stores the session in the database behind a signed cookie" do
    raw = start_session

    row = BrowserSession.sole
    expect(row.session_id).to eq private_id(verified(raw))
    expect(row).to be_signed_cookie
    expect(row.session_data).to include("cookie_preference_referer" => referer)
    expect(row.expires_at).to be_within(1.minute).of(1.hour.from_now)
  end

  it "resumes the session on the next request" do
    raw = start_session
    first_row_id = BrowserSession.sole.session_id
    save_preference.call

    expect(BrowserSession.sole.session_id).to eq first_row_id
    expect(current_public_id).to eq verified(raw)
    expect(BrowserSession.sole.session_data).to include("flash")
  end

  it "ignores a tampered signed cookie" do
    raw = start_session
    cookies[cookie_name] = raw.sub(/.\z/) { |c| c == "a" ? "b" : "a" }
    save_preference.call

    expect(current_public_id).not_to eq verified(raw)
  end

  it "ignores the unsigned public id once the session has a signed cookie" do
    public_id = verified(start_session)
    cookies[cookie_name] = public_id
    save_preference.call

    expect(current_public_id).not_to eq public_id
  end

  it "ignores an expired session without waiting for cleanup" do
    public_id = verified(start_session)
    BrowserSession.update_all expires_at: 1.minute.ago
    save_preference.call

    expect(current_public_id).not_to eq public_id
  end

  it "ignores a deleted session" do
    public_id = verified(start_session)
    BrowserSession.delete_all
    save_preference.call

    expect(current_public_id).not_to eq public_id
  end

  describe "a session whose cookie predates signing" do
    before do
      legacy_row("legacycookievalue")
      cookies[cookie_name] = "legacycookievalue"
    end

    it "keeps its data and is moved to a signed cookie" do
      save_preference.call

      expect(current_public_id).to eq "legacycookievalue"
      expect(verified(cookies[cookie_name])).to eq "legacycookievalue"
      expect(BrowserSession.sole).to be_signed_cookie
    end

    it "cannot be used unsigned again once upgraded" do
      save_preference.call
      cookies[cookie_name] = "legacycookievalue"
      save_preference.call

      expect(current_public_id).not_to eq "legacycookievalue"
    end

    it "is not revived once its row has been deleted" do
      BrowserSession.delete_all
      save_preference.call

      expect(current_public_id).not_to eq "legacycookievalue"
    end
  end

  describe "in the redis phase", storage_phase: "redis" do
    it "keeps an unsigned cookie and the data in redis, shadowed to the database" do
      public_id = start_session
      key = "_session_id:#{private_id(public_id)}"

      expect(cookies[cookie_name]).to eq public_id
      expect(Rails.cache.read(key)).to include("cookie_preference_referer" => referer)
      expect(BrowserSession.sole.session_id).to eq private_id(public_id)
    ensure
      Rails.cache.delete key
    end

    it "continues a session created by pre-database code" do
      key = "_session_id:#{private_id('oldpodcookie')}"
      Rails.cache.write key, { "cookie_preference_referer" => referer }, expires_in: 1.hour
      cookies[cookie_name] = "oldpodcookie"
      save_preference.call

      expect(cookies[cookie_name]).to eq "oldpodcookie"
      expect(Rails.cache.read(key)).to include("flash")
    ensure
      Rails.cache.delete key
    end
  end

  describe "in the dual phase", storage_phase: "dual" do
    it "keeps an unsigned cookie compatible with pre-database code and mirrors to redis" do
      public_id = start_session
      key = "_session_id:#{private_id(public_id)}"

      expect(cookies[cookie_name]).to eq public_id
      expect(Rails.cache.read(key)).to include("cookie_preference_referer" => referer)
      expect(BrowserSession.sole).not_to be_signed_cookie
    ensure
      Rails.cache.delete key
    end

    it "keeps a signed cookie signed" do
      legacy_row("signedcookievalue", signed_cookie: true)
      cookies[cookie_name] = signed("signedcookievalue")
      save_preference.call

      expect(verified(cookies[cookie_name])).to eq "signedcookievalue"
      expect(BrowserSession.sole).to be_signed_cookie
    ensure
      Rails.cache.delete "_session_id:#{private_id('signedcookievalue')}"
    end
  end
end
