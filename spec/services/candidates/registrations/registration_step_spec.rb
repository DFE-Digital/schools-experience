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

  context '#save' do
    context 'without registration session' do
      subject do
        build :background_check
      end

      it 'raises an error' do
        expect { subject.save }.to raise_error RuntimeError,
          'registration_session not set. Instantiate with `RegistrationSession#build_background_check` to ensure registration_session is set'
      end
    end

    context 'with registration session' do
      let :registration_session do
        build :flattened_registration_session, with: []
      end

      before do
        subject.registration_session = registration_session
      end

      context 'when invalid' do
        subject do
          build :background_check, has_dbs_check: nil
        end

        it 'returns false' do
          expect(subject.save).to be false
        end

        it 'adds errors to the model' do
          expect(subject.tap(&:save)).not_to be_valid
        end
      end

      context 'when valid' do
        subject do
          build :background_check
        end

        it 'saves the step in the registration session' do
          subject.save
          expect(registration_session.background_check).to eq_model subject
        end
      end
    end
  end

  context '#update' do
    subject do
      build :background_check
    end

    context 'without registration session' do
      it 'raises an error' do
        expect { subject.update has_dbs_check: false }.to raise_error RuntimeError,
          'registration_session not set. Instantiate with `RegistrationSession#build_background_check` to ensure registration_session is set'
      end
    end

    context 'with registration_session' do
      let :registration_session do
        build :flattened_registration_session, with: []
      end

      before do
        subject.registration_session = registration_session
      end

      context 'when invalid' do
        let :params do
          { has_dbs_check: nil }
        end

        it 'returns false' do
          expect(subject.update(params)).to be false
        end

        it 'adds errors to the model' do
          expect(subject.tap { |s| s.update params }).not_to be_valid
        end
      end

      context 'when valid' do
        let :params do
          { has_dbs_check: !subject.has_dbs_check }
        end

        it 'saves the updated step in the registration_session' do
          subject.update params
          expect(registration_session.background_check.has_dbs_check).to eq \
            subject.has_dbs_check
        end
      end
    end
  end
end
