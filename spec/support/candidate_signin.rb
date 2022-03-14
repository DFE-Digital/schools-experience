shared_context 'candidate signin' do
  let(:gitis_contact_attrs) { attributes_for(:api_schools_experience_sign_up_with_name) }
  let(:gitis_contact) { build(:api_schools_experience_sign_up_with_name, gitis_contact_attrs) }
  let(:current_candidate) do
    create(:candidate, :confirmed, gitis_uuid: gitis_contact.candidate_id, gitis_contact: gitis_contact)
  end

  before do
    allow_any_instance_of(described_class).to \
      receive(:current_contact).and_return(gitis_contact)

    allow(Bookings::Candidate).to receive(:find_by_gitis_contact).and_return(current_candidate)
  end
end
