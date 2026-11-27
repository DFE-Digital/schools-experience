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

  context 'in the redis phase', storage_phase: 'redis' do
    it 'stores in redis with a one day expiry and shadows to the database' do
      subject.store! session

      expect(redis.get(legacy_key)).to eq session.to_json
      expect(redis.ttl(legacy_key)).to be_within(5).of(1.day.to_i)
      expect(CandidateRegistration.find_by!(uuid: 'sekret').registration_data).to eq session.to_json
    end

    it 'reads a registration written only by pre-database code' do
      redis.set legacy_key, session.to_json, ex: 3_600

      expect(subject.retrieve!('sekret')).to eq session
      expect(subject.has_registration?('sekret')).to eq true
    end

    it 'ignores a database copy that redis no longer has' do
      subject.store! session
      redis.del legacy_key

      expect { subject.retrieve! 'sekret' }.to raise_error described_class::SessionNotFound
      expect(subject.has_registration?('sekret')).to eq false
    end

    it 'deletes both copies and cannot be deleted twice' do
      subject.store! session
      subject.delete! 'sekret'

      expect(redis.exists?(legacy_key)).to eq false
      expect(CandidateRegistration.where(uuid: 'sekret')).to be_empty
      expect { subject.delete! 'sekret' }.to raise_error described_class::SessionNotFound
    end
  end

  context 'in the dual phase', storage_phase: 'dual' do
    it 'stores in the database and mirrors to redis for pre-database code' do
      subject.store! session

      expect(CandidateRegistration.find_by!(uuid: 'sekret').registration_data).to eq session.to_json
      expect(redis.get(legacy_key)).to eq session.to_json
      expect(redis.ttl(legacy_key)).to be_within(5).of(1.day.to_i)
    end

    it 'reads the database and never revives a record from redis' do
      subject.store! session
      CandidateRegistration.delete_all

      expect { subject.retrieve! 'sekret' }.to raise_error described_class::SessionNotFound
      expect(subject.has_registration?('sekret')).to eq false
    end

    it 'treats an expired database record as missing even though redis still has it' do
      subject.store! session
      CandidateRegistration.update_all expires_at: 1.second.ago

      expect { subject.retrieve! 'sekret' }.to raise_error described_class::SessionNotFound
      expect { subject.delete! 'sekret' }.to raise_error described_class::SessionNotFound
    end

    it 'deletes both copies' do
      subject.store! session
      subject.delete! 'sekret'

      expect(redis.exists?(legacy_key)).to eq false
      expect(CandidateRegistration.where(uuid: 'sekret')).to be_empty
    end
  end

  context 'in the database phase' do
    it 'neither reads nor writes redis' do
      redis.set legacy_key, session.to_json, ex: 3_600

      expect { subject.retrieve! 'sekret' }.to raise_error described_class::SessionNotFound

      subject.store! other = FactoryBot.build(:registration_session, uuid: 'other')
      expect(redis.exists?("test:registrations:#{other.uuid}")).to eq false
      expect(redis.exists?(legacy_key)).to eq true
    ensure
      redis.del "test:registrations:other"
    end
  end

  # Needs real concurrent connections, so the example can't be wrapped in a
  # transaction
  context 'when a delete overlaps a store', storage_phase: 'dual' do
    self.use_transactional_tests = false
    after do
      CandidateRegistration.delete_all
      # the session factory creates a school, type and dates outside a rolled-back transaction
      ActiveRecord::Base.connection.execute("TRUNCATE bookings_school_types CASCADE")
    end

    it 'cannot leave a deleted registration behind in either store' do
      writing = Queue.new
      slow_set = redis.method(:set)
      allow(redis).to receive(:set) do |*args, **kwargs|
        writing << :in_store
        sleep 0.3
        slow_set.call(*args, **kwargs)
      end

      registration = session
      store = Thread.new { subject.store! registration }
      writing.pop
      subject.delete! 'sekret'
      store.join

      expect(redis.exists?(legacy_key)).to eq false
      expect(CandidateRegistration.where(uuid: 'sekret')).to be_empty
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
