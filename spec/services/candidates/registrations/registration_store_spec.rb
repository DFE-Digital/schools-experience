require 'rails_helper'

describe Candidates::Registrations::RegistrationStore do
  let :redis do
    Redis.current
  end

  let :session do
    build :flattened_registration_session, uuid: 'sekret'
  end

  subject { described_class.instance }

  context '#store!' do
    let! :returned_uuid do
      subject.store! session
    end

    it 'stores the key in redis correctly' do
      expect(redis.get("test:registrations:sekret")).to eq \
        session.to_json
    end

    it 'stores the key with the correct ttl' do
      expect(redis.ttl("test:registrations:sekret")).to eq 86400
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

      it 'removes the key from redis' do
        expect(redis.get("test:registrations:sekret")).to eq nil
      end
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
