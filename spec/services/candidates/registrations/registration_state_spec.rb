require 'rails_helper'

describe Candidates::Registrations::RegistrationState do
  before do
    FactoryBot.create :bookings_school, urn: 11048
  end

  subject { described_class.new registration_session }

  context 'without personal information' do
    let :registration_session do
      Candidates::Registrations::RegistrationSession.new('urn' => '11048')
    end

    it { expect(subject.next_step).to eq :personal_information }
    it { is_expected.not_to be_completed }
  end

  context 'with personal information' do
    let :registration_session do
      FactoryBot.build :registration_session, with: [:personal_information]
    end

    it { expect(subject.next_step).to eq :contact_information }
    it { is_expected.not_to be_completed }
  end

  context 'with contact_information' do
    let :registration_session do
      FactoryBot.build :registration_session,
        with: %i(personal_information contact_information)
    end

    it { expect(subject.next_step).to eq :education }
    it { is_expected.not_to be_completed }
  end

  context 'with education' do
    let :registration_session do
      FactoryBot.build :registration_session,
        with: %i(personal_information contact_information education)
    end

    it { expect(subject.next_step).to eq :teaching_preference }
    it { is_expected.not_to be_completed }
  end

  context 'with teaching_preference' do
    let :registration_session do
      FactoryBot.build :registration_session, with: %i(
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
      FactoryBot.build :registration_session, with: %i(
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
      FactoryBot.build :registration_session, with: %i(
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
