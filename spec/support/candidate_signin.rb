shared_context 'when the candidate signs in' do
  let(:gitis_contact_attrs) { attributes_for(:api_schools_experience_sign_up_with_name) }
  let(:gitis_contact) { build(:api_schools_experience_sign_up_with_name, gitis_contact_attrs) }
  let(:current_candidate) do
    create(:candidate, :confirmed, gitis_uuid: gitis_contact.candidate_id, gitis_contact: gitis_contact)
  end

  before do
    allow(described_class).to receive(:new).and_wrap_original do |original, *args|
      original.call(*args).tap do |controller|
        allow(controller).to receive(:current_contact).and_return(gitis_contact)
      end
    end

    allow(Bookings::Candidate).to receive(:find_by_gitis_contact).and_return(current_candidate)
  end
end
