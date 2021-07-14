shared_context 'candidate signin' do
  let(:gitis_contact_attrs) { attributes_for(:api_schools_experience_sign_up) }
  let(:gitis_contact) { build(:api_schools_experience_sign_up, gitis_contact_attrs) }
  let(:current_candidate) { create(:candidate, gitis_uuid: gitis_contact.candidate_id) }

  before do
    allow_any_instance_of(described_class).to \
      receive(:current_contact).and_return(gitis_contact)

    allow_any_instance_of(described_class).to \
      receive(:current_candidate).and_return(current_candidate)
  end
end
