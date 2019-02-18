shared_context 'Stubbed candidates school' do
  let :school_urn do
    'URN'
  end

  let :subjects do
    [
      { name: 'Geography' },
      { name: 'Architecture' },
      { name: 'Mathematics' },
    ]
  end

  let :school do
    double Bookings::School, id: school_urn, subjects: subjects
  end

  let :allowed_subject_choices do
    school.subjects.pluck :name
  end

  before do
    allow(Candidates::School).to receive(:find) { school }
  end
end
