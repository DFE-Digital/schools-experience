require "rails_helper"

describe ActionDispatch::Session::DatabaseStore do
  let(:options) { { expire_after: 3.hours } }
  let(:store) { described_class.new(->(_env) {}, options.dup) }
  let(:request) { ActionDispatch::Request.empty }
  let(:sid) { store.generate_sid }
  let(:legacy_key) { "_session_id:#{sid.private_id}" }

  after { Rails.cache.delete legacy_key }

  def load(session_id = sid, req = ActionDispatch::Request.empty)
    [req, *store.find_session(req, session_id)]
  end

  describe "round trip" do
    it "stores the payload against the hashed id and preserves its types" do
      payload = { "date" => Date.new(2030, 1, 2), "nested" => { "a" => [1, "b"] } }
      store.write_session(request, sid, payload, options)

      expect(BrowserSession.pluck(:session_id)).to eq [sid.private_id]
      expect(sid.private_id).not_to include sid.public_id
      expect(load.last).to eq payload
    end

    it "expires from the last write" do
      store.write_session(request, sid, { "a" => 1 }, options)

      expect(BrowserSession.first.expires_at).to be_within(5.seconds).of(3.hours.from_now)
    end

    it "ignores expired rows that cleanup has not removed" do
      store.write_session(request, sid, { "a" => 1 }, options)
      BrowserSession.update_all expires_at: 1.second.ago

      _req, new_sid, data = load
      expect(data).to eq({})
      expect(new_sid.public_id).not_to eq sid.public_id
    end

    it "gives an unknown id a fresh session" do
      _req, new_sid, data = load(store.generate_sid)

      expect(data).to eq({})
      expect(new_sid.public_id).to be_present
    end
  end

  describe "revocation" do
    it "deletes the row when the session is destroyed" do
      store.write_session(request, sid, { "a" => 1 }, options)
      store.delete_session(request, sid, options)

      expect(BrowserSession.count).to eq 0
    end

    it "deletes the row when the session is cleared" do
      store.write_session(request, sid, { "a" => 1 }, options)
      store.write_session(request, sid, {}, options)

      expect(BrowserSession.count).to eq 0
    end

    it "does not resurrect a session deleted by another request" do
      store.write_session(request, sid, { "a" => 1 }, options)
      req, = load
      BrowserSession.delete_all

      expect(store.write_session(req, sid, { "a" => 2 }, options)).to be false
      expect(BrowserSession.count).to eq 0
    end
  end

  # Sessions created before the move to the database are still in the cache
  describe "legacy cache sessions" do
    before { Rails.cache.write legacy_key, { "marker" => "legacy" }, expires_in: 1.hour }

    it "are read, then moved to the database when the request ends" do
      req, _sid, data = load
      expect(data).to eq("marker" => "legacy")

      store.write_session(req, sid, data.merge("more" => 1), options)

      expect(Rails.cache.exist?(legacy_key)).to be false
      expect(load.last).to eq("marker" => "legacy", "more" => 1)
    end

    it "are not resurrected if logged out during the request" do
      req, _sid, data = load
      Rails.cache.delete legacy_key

      expect(store.write_session(req, sid, data, options)).to be false
      expect(BrowserSession.count).to eq 0
    end

    it "are removed on logout" do
      store.delete_session(request, sid, options)

      expect(Rails.cache.exist?(legacy_key)).to be false
    end
  end
end
