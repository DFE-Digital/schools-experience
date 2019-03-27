shared_context 'Stubbed candidates school' do
  let :school_urn do
    11048
  end

  let :school do
    FactoryBot.build_stubbed \
      :bookings_school,
      name: 'Test School',
      contact_email: 'test@test.com',
      urn: school_urn
  end

  let :allowed_subject_choices do
    Bookings::Subject.all.pluck(:name)
  end

  let :second_subject_choices do
    ["I don't have a second subject"] + allowed_subject_choices
  end

  before do
    allow(Candidates::School).to receive(:find) { school }
  end
end
