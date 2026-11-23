require "rails_helper"

describe ActionDispatch::Session::DatabaseStore do
  let(:options) { { expire_after: 3.hours } }
  let(:store) { described_class.new(->(_env) {}, options.dup) }
  let(:request) { ActionDispatch::Request.empty }
  let(:sid) { store.generate_sid }
  let(:redis_key) { "_session_id:#{sid.private_id}" }

  after { Rails.cache.delete redis_key }

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

    it "does not touch redis" do
      store.write_session(request, sid, { "a" => 1 }, options)

      expect(Rails.cache.exist?(redis_key)).to be false
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

  describe "in the redis phase", storage_phase: "redis" do
    before { Rails.cache.write redis_key, { "marker" => "redis" }, expires_in: 1.hour }

    it "reads redis, ignoring the database" do
      BrowserSession.create!(session_id: sid.private_id, session_data: BrowserSession.dump("marker" => "db"), expires_at: 1.hour.from_now)

      expect(load.last).to eq("marker" => "redis")
    end

    it "writes redis and shadows the database" do
      req, _sid, data = load
      store.write_session(req, sid, data.merge("more" => 1), options)

      expect(Rails.cache.read(redis_key)).to eq("marker" => "redis", "more" => 1)
      expect(BrowserSession.sole.payload).to eq("marker" => "redis", "more" => 1)
    end

    it "is not restored by a request still using it after logout" do
      req, _sid, data = load
      Rails.cache.delete redis_key

      expect(store.write_session(req, sid, data, options)).to be false
      expect(Rails.cache.exist?(redis_key)).to be false
      expect(BrowserSession.count).to eq 0
    end

    it "removes both copies on logout" do
      req, _sid, data = load
      store.write_session(req, sid, data, options)
      store.delete_session(request, sid, options)

      expect(Rails.cache.exist?(redis_key)).to be false
      expect(BrowserSession.count).to eq 0
    end
  end

  describe "signing is monotonic across phases", storage_phase: "dual" do
    it "does not downgrade a row another pod signed after this request loaded it" do
      store.write_session(request, sid, { "a" => 1 }, options)
      req, = load
      expect(req.get_header(described_class::SIGNED_COOKIE)).to be_nil
      BrowserSession.update_all(signed_cookie: true) # a database-phase pod upgrades it meanwhile

      store.write_session(req, sid, { "a" => 2 }, options)

      expect(BrowserSession.sole.signed_cookie).to be true
      expect(req.get_header(described_class::SIGNED_COOKIE)).to be true
    end

    it "does not downgrade on an upsert of an already signed row" do
      store.write_session(request, sid, { "a" => 1 }, options)
      BrowserSession.update_all(signed_cookie: true)

      store.write_session(ActionDispatch::Request.empty, sid, { "a" => 2 }, options)

      expect(BrowserSession.sole.signed_cookie).to be true
    end
  end

  describe "in the dual phase", storage_phase: "dual" do
    it "reads only the database, never reviving a session from redis" do
      Rails.cache.write redis_key, { "marker" => "redis" }, expires_in: 1.hour

      expect(load.last).to eq({})
    end

    it "mirrors writes to redis for pre-database code" do
      store.write_session(request, sid, { "a" => 1 }, options)

      expect(Rails.cache.read(redis_key)).to eq("a" => 1)
      expect(BrowserSession.sole.payload).to eq("a" => 1)
    end

    it "fails the write, leaving no database-only state, when the redis mirror fails" do
      allow(Rails.cache).to receive(:write).and_return(false)

      expect { store.write_session(request, sid, { "a" => 1 }, options) }.to raise_error(/mirror/)
      expect(BrowserSession.count).to eq 0
    end

    it "does not recreate the redis copy of a session deleted during the request" do
      store.write_session(request, sid, { "a" => 1 }, options)
      req, = load
      store.delete_session(request, sid, options)

      expect(store.write_session(req, sid, { "a" => 2 }, options)).to be false
      expect(Rails.cache.exist?(redis_key)).to be false
      expect(BrowserSession.count).to eq 0
    end

    it "removes both copies on logout" do
      store.write_session(request, sid, { "a" => 1 }, options)
      store.write_session(request, sid, {}, options)

      expect(Rails.cache.exist?(redis_key)).to be false
      expect(BrowserSession.count).to eq 0
    end
  end

  # Needs real concurrent connections, so the example can't be wrapped in a
  # transaction
  describe "when a logout overlaps a write", storage_phase: "dual" do
    self.use_transactional_tests = false
    after { BrowserSession.delete_all }

    it "cannot leave the session alive in either store" do
      store.write_session(request, sid, { "a" => 1 }, options)
      req, = load
      writing = Queue.new
      original = Rails.cache.method(:write)
      allow(Rails.cache).to receive(:write) do |*args, **kwargs|
        writing << :in_write
        sleep 0.3
        original.call(*args, **kwargs)
      end

      write = Thread.new { store.write_session(req, sid, { "a" => 2 }, options) }
      writing.pop
      store.delete_session(request, sid, options)
      write.join

      expect(Rails.cache.exist?(redis_key)).to be false
      expect(BrowserSession.count).to eq 0
    end
  end
end
