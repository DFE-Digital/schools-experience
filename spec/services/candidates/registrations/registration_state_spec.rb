require 'rails_helper'

describe Candidates::Registrations::RegistrationState do
  let :school do
    create :bookings_school, urn: 11048
  end

  let :school_with_flexible_dates do
    create :bookings_school, availability_preference_fixed: false
  end

  let :school_with_fixed_dates do
    create :bookings_school, availability_preference_fixed: true
  end

  subject { described_class.new registration_session }

  context '#steps' do
    context 'for a school with flexible dates' do
      let :registration_session do
        build :registration_session, urn: school_with_flexible_dates.urn, with: []
      end

      it 'returns the correct steps' do
        expect(subject.steps).to eq %i(
          personal_information
          contact_information
          education
          teaching_preference
          placement_preference
          background_check
        )
      end
    end

    context 'for a school with fixed dates' do
      let :registration_session do
        build :registration_session, urn: school_with_fixed_dates.urn, with: []
      end

      it 'returns the correct steps' do
        expect(subject.steps).to eq %i(
          subject_and_date_information
          personal_information
          contact_information
          education
          teaching_preference
          placement_preference
          background_check
        )
      end
    end
  end

  context 'for a school with fixed dates' do
    context 'without subject_and_date_information' do
      let :registration_session do
        build :registration_session, urn: school_with_fixed_dates.urn, with: []
      end

      it { expect(subject.next_step).to eq :subject_and_date_information }
    end

    context 'with subject_and_date_information' do
      let :registration_session do
        build :registration_session, urn: school_with_fixed_dates.urn,
          with: %i(subject_and_date_information)
      end

      it { expect(subject.next_step).to eq :personal_information }
    end
  end

  context 'without personal information' do
    let :registration_session do
      build :registration_session, urn: school.urn, with: []
    end

    it { expect(subject.next_step).to eq :personal_information }
    it { is_expected.not_to be_completed }
  end

  context 'with personal information' do
    let :registration_session do
      build :registration_session, urn: school.urn, with: [:personal_information]
    end

    it { expect(subject.next_step).to eq :contact_information }
    it { is_expected.not_to be_completed }
  end

  context 'with contact_information' do
    let :registration_session do
      build :registration_session, urn: school.urn,
        with: %i(personal_information contact_information)
    end

    it { expect(subject.next_step).to eq :education }
    it { is_expected.not_to be_completed }
  end

  context 'with education' do
    let :registration_session do
      build :registration_session, urn: school.urn,
        with: %i(personal_information contact_information education)
    end

    it { expect(subject.next_step).to eq :teaching_preference }
    it { is_expected.not_to be_completed }
  end

  context 'with teaching_preference' do
    let :registration_session do
      build :registration_session, urn: school.urn, with: %i(
        personal_information
        contact_information
        education
        teaching_preference
      )
    end

    it { expect(subject.next_step).to eq :placement_preference }
    it { is_expected.not_to be_completed }
  end

  context 'with placement_preference' do
    let :registration_session do
      build :registration_session, urn: school.urn, with: %i(
        personal_information
        contact_information
        education
        teaching_preference
        placement_preference
      )
    end

    it { expect(subject.next_step).to eq :background_check }
    it { is_expected.not_to be_completed }
  end

  context 'with background_check' do
    let :registration_session do
      build :registration_session, urn: school.urn, with: %i(
        personal_information
        contact_information
        education
        teaching_preference
        placement_preference
        background_check
      )
    end

    it { expect(subject.next_step).to eq :COMPLETED }
    it { is_expected.to be_completed }
  end
end
