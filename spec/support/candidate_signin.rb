shared_context 'candidate signin' do
  let(:gitis_contact_attrs) { attributes_for(:gitis_contact, :persisted) }
  let(:gitis_contact) { build(:gitis_contact, gitis_contact_attrs) }
  let(:current_candidate) { build(:candidate, gitis_uuid: gitis_contact.id) }

  before do
    allow_any_instance_of(described_class).to \
      receive(:current_contact).and_return(gitis_contact)

    allow_any_instance_of(described_class).to \
      receive(:current_candidate).and_return(current_candidate)
  end
end
