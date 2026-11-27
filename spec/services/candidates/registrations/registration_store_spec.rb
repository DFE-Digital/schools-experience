require 'rails_helper'

describe Candidates::Registrations::RegistrationStore do
  subject { described_class.instance }

  let :redis do
    REDIS
  end

  let :session do
    FactoryBot.build :registration_session, uuid: 'sekret'
  end

  describe '#store!' do
    before do
      subject.store! session
    end

    it 'stores the key in redis correctly' do
      expect(redis.get("test:registrations:sekret")).to eq \
        session.to_json
    end

    it 'stores the key with the correct ttl' do
      expect(redis.ttl("test:registrations:sekret")).to eq 86_400
    end
  end

  describe '#store! with a blank key' do
    before do
      allow(session).to receive(:uuid).and_return(nil)
    end

    it 'raises an error' do
      expect { subject.store! session }.to \
        raise_error(described_class::NoKey).with_message \
          "`registration_session#uuid` can't be blank"
    end
  end

  describe '#get!' do
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

  describe '#delete!' do
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
        expect(redis.get("test:registrations:sekret")).to be_nil
      end
    end
  end

  describe '#has_registration?' do
    before do
      subject.store! session
    end

    context 'when registration does not exist' do
      it 'returns false' do
        expect(subject.has_registration?('bad-uuid')).to be false
      end
    end

    context 'when registration exists' do
      it 'returns true' do
        expect(subject.has_registration?(session.uuid)).to be true
      end
    end
  end
end
