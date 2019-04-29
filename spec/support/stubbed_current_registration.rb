shared_context 'Stubbed current_registration' do
  before do
    allow_any_instance_of(described_class).to \
      receive(:current_registration) { registration_session }
  end
end
