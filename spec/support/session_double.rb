shared_context "session double" do
  let(:session_hash) { {} }

  before do
    session_double = instance_double(ActionDispatch::Request::Session, enabled?: true, loaded?: false)

    allow(session_double).to receive(:[]) do |key|
      session_hash[key]
    end
    allow(session_double).to receive(:[]=) do |key, value|
      session_hash[key] = value
    end

    allow(session_double).to receive(:delete) do |key|
      session_hash.delete(key)
    end

    allow(session_double).to receive(:clear) do |_key|
      session_hash.clear
    end

    allow(session_double).to receive(:fetch) do |key|
      session_hash.fetch(key)
    end

    allow(session_double).to receive(:key?) do |key|
      session_hash.key?(key)
    end

    allow_any_instance_of(ActionDispatch::Request)
      .to receive(:session).and_return(session_double)
  end
end
