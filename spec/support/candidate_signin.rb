shared_context 'candidate signin' do
  let(:gitis_contact_attrs) { attributes_for(:gitis_contact, :persisted) }
  let(:gitis_contact) { build(:gitis_contact, gitis_contact_attrs) }

  before do
    allow_any_instance_of(described_class).to \
      receive(:current_user).and_return(build(:gitis_contact, :persisted))
  end
end
