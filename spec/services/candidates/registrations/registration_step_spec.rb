require 'rails_helper'

describe Candidates::Registrations::RegistrationStep, type: :model do
  context '.new_from_session' do
    subject do
      Candidates::Registrations::PlacementPreference.new_from_session session
    end

    context 'when the session contains the necessary attributes' do
      let :session do
        attributes_for(:placement_preference).merge \
          'placement_preference_created_at' => DateTime.now,
          'placement_preference_updated_at' => DateTime.now
      end

      it { is_expected.to be_persisted }
    end

    context 'when the session does not contain the necessary attributes' do
      let :session do
        {}
      end

      it { is_expected.not_to be_persisted }
    end

    context 'when the session does not contain timestamps' do
      let :session do
        attributes_for(:placement_preference)
      end

      it { is_expected.not_to be_persisted }
    end
  end
end
