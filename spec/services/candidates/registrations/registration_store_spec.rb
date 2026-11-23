require 'rails_helper'

describe Candidates::Registrations::RegistrationStore do
  let :redis do
    REDIS
  end

  let :session do
    FactoryBot.build :registration_session, uuid: 'sekret'
  end

  let(:legacy_key) { "test:registrations:sekret" }

  subject { described_class.instance }

  after { redis.del legacy_key }

  context '#store!' do
    let! :returned_uuid do
      subject.store! session
    end

    it 'stores the registration JSON in the database unchanged' do
      expect(CandidateRegistration.find_by!(uuid: 'sekret').registration_data).to \
        eq session.to_json
    end

    it 'stores the registration with a one day expiry' do
      expect(CandidateRegistration.find_by!(uuid: 'sekret').expires_at).to \
        be_within(5.seconds).of(1.day.from_now)
    end

    it 'does not write to redis' do
      expect(redis.exists?(legacy_key)).to eq false
    end
  end

  context '#store! when the registration already exists' do
    it 'replaces the data and renews the expiry' do
      subject.store! session
      CandidateRegistration.update_all expires_at: 1.minute.from_now
      session.flag_as_completed!
      subject.store! session

      expect(CandidateRegistration.where(uuid: 'sekret').count).to eq 1
      expect(subject.retrieve!('sekret')).to be_completed
      expect(CandidateRegistration.find_by!(uuid: 'sekret').expires_at).to \
        be_within(5.seconds).of(1.day.from_now)
    end

    it 'revives an expired record under the same uuid' do
      subject.store! session
      CandidateRegistration.update_all expires_at: 1.minute.ago
      subject.store! session

      expect(subject.has_registration?('sekret')).to eq true
    end
  end

  context '#store! with a blank key' do
    before do
      allow(session).to receive(:uuid) { nil }
    end

    it 'raises an error' do
      expect { subject.store! session }.to \
        raise_error(described_class::NoKey).with_message \
          "`registration_session#uuid` can't be blank"
    end
  end

  context '#get!' do
    before do
      subject.store! session
    end

    let :returned do
      subject.retrieve! 'sekret'
    end

    it 'raises when the key is not found' do
      expect { subject.retrieve! 'missing' }.to raise_error \
        described_class::SessionNotFound
    end

    it 'returns the session when the key is found' do
      expect(returned).to eq session
    end

    it 'treats an expired registration as missing without cleanup' do
      CandidateRegistration.update_all expires_at: 1.second.ago

      expect { subject.retrieve! 'sekret' }.to raise_error \
        described_class::SessionNotFound
      expect(subject.has_registration?('sekret')).to eq false
      expect(CandidateRegistration.count).to eq 1
    end

    it 'preserves date times when deserializing' do
      expect(returned.placement_preference.created_at.to_i).to \
        eq session.placement_preference.created_at.to_i
    end
  end

  context '#delete!' do
    before do
      subject.store! session
    end

    context 'when key does not exist' do
      it 'raises' do
        expect { subject.delete! 'missing' }.to raise_error \
          described_class::SessionNotFound
      end
    end

    context 'when key does exist' do
      before do
        subject.delete! "sekret"
      end

      it 'removes the registration from the database' do
        expect(CandidateRegistration.where(uuid: 'sekret')).to be_empty
      end

      it 'cannot be deleted twice' do
        expect { subject.delete! 'sekret' }.to raise_error \
          described_class::SessionNotFound
      end
    end

    context 'when the registration has expired' do
      it 'raises' do
        CandidateRegistration.update_all expires_at: 1.second.ago

        expect { subject.delete! 'sekret' }.to raise_error \
          described_class::SessionNotFound
      end
    end
  end

  # Registrations created before the move to the database are still in Redis
  context 'legacy registrations stored in redis' do
    before do
      redis.set legacy_key, session.to_json, ex: 3_600
    end

    it 'is found and moved to the database with its remaining lifetime' do
      expect(subject.retrieve!('sekret')).to eq session

      record = CandidateRegistration.find_by!(uuid: 'sekret')
      expect(record.expires_at).to be_within(10.seconds).of(1.hour.from_now)
      expect(redis.exists?(legacy_key)).to eq false
    end

    it 'is reported by has_registration?' do
      expect(subject.has_registration?('sekret')).to eq true
    end

    it 'does not overwrite a newer database record' do
      subject.store! session
      newer = FactoryBot.build :registration_session, uuid: 'sekret'
      newer.flag_as_completed!
      subject.store! newer

      expect(subject.retrieve!('sekret')).to be_completed
    end

    it 'is removed from redis by delete! so it cannot come back' do
      subject.delete! 'sekret'

      expect(redis.exists?(legacy_key)).to eq false
      expect { subject.retrieve! 'sekret' }.to raise_error \
        described_class::SessionNotFound
    end

    it 'is deleted along with a database copy' do
      subject.store! session
      subject.delete! 'sekret'

      expect(redis.exists?(legacy_key)).to eq false
      expect(subject.has_registration?('sekret')).to eq false
    end
  end

  context '#has_registration?' do
    let! :returned_uuid do
      subject.store! session
    end

    context 'when registration does not exist' do
      it 'returns false' do
        expect(subject.has_registration?('bad-uuid')).to eq false
      end
    end

    context 'when registration exists' do
      it 'returns true' do
        expect(subject.has_registration?(session.uuid)).to eq true
      end
    end
  end
end
