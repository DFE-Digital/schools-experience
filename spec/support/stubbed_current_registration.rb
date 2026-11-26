shared_context 'with a stubbed current registration' do
  before do
    allow(described_class).to receive(:new).and_wrap_original do |original, *args|
      original.call(*args).tap do |controller|
        allow(controller).to receive(:current_registration).and_return(registration_session)
      end
    end
  end
end
