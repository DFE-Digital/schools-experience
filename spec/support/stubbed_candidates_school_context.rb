shared_context 'Stubbed candidates school' do |fixed|
  let :school_urn do
    11048
  end

  let :school do
    Bookings::School.find_by(urn: school_urn) ||
      create(:bookings_school,
        name: 'Test School',
        contact_email: 'test@test.com',
        urn: school_urn,
        availability_preference_fixed: fixed)
  end

  let :allowed_subject_choices do
    Bookings::Subject.pluck(:name)
  end

  let :second_subject_choices do
    ["I don't have a second subject"] + allowed_subject_choices
  end

  before do
    allow(Candidates::School).to receive(:find) { school }
  end
end
