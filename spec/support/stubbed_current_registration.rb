shared_context 'with a stubbed current registration' do
  before do
    allow_any_instance_of(described_class) # rubocop:disable RSpec/AnyInstance -- request specs create controller instances internally, and this composes with other instance stubs.
      .to receive(:current_registration).and_return(registration_session)
  end
end
