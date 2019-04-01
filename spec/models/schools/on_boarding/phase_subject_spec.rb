require 'rails_helper'

describe Schools::OnBoarding::PhaseSubject, type: :model do
  it { is_expected.to belong_to :schools_school_profile }
  it { is_expected.to belong_to :phase }
  it { is_expected.to belong_to :subject }
  it { is_expected.to validate_presence_of :schools_school_profile }
  it { is_expected.to validate_presence_of :subject }
  it { is_expected.to validate_presence_of :phase }

  context '.at_phase' do
    let :school_profile do
      FactoryBot.create :school_profile
    end

    let :bookings_phase_1 do
      FactoryBot.create :bookings_phase
    end

    let :bookings_phase_2 do
      FactoryBot.create :bookings_phase
    end

    let :bookings_subject do
      FactoryBot.create :bookings_subject
    end

    let! :expected_phase_subject do
      described_class.create! \
        schools_school_profile: school_profile,
        phase: bookings_phase_1,
        subject: bookings_subject
    end

    let! :unexpected_phase_subject do
      described_class.create! \
        schools_school_profile: school_profile,
        phase: bookings_phase_2,
        subject: bookings_subject
    end

    it 'returns the correct phase_subjects' do
      expect(described_class.at_phase(bookings_phase_1)).to \
        include expected_phase_subject

      expect(described_class.at_phase(bookings_phase_1)).not_to \
        include unexpected_phase_subject
    end
  end
end
