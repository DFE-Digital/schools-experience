require 'rails_helper'

describe Candidates::Registrations::RegistrationStore do
  include_context 'redis'

  let :session do
    FactoryBot.build :registration_session
  end

  let :uuid do
    allow(SecureRandom).to receive(:urlsafe_base64) { 'sekret_key' }
    described_class.store session
  end

  before do
    # We're namespacing all our test redis keys under 'TEST'
    # See spec/support/redis.rb
    allow(described_class).to receive(:namespace) do
      "#{test_namespace}:pending_confirmations"
    end

    uuid
  end

  context '.store' do
    it 'writes the session to the cache under a random key' do
      expect(Rails.cache.read('pending_confirmations:sekret_key')).to eq \
        session.to_h
    end

    it 'returns the key' do
      expect(uuid).to eq 'sekret_key'
    end
  end

  context '.find_by!' do
    context 'when key is not found' do
      it 'raises' do
        expect { described_class.find_by! uuid: 'bad_id' }.to raise_error \
          described_class::SessionNotFound
      end
    end

    context 'when key is found' do
      it 'returns the session' do
        expect(described_class.find_by!(uuid: 'sekret_key')).to eq session
      end
    end
  end

  context '.remove!' do
    before do
      allow(Rails.cache).to receive(:delete)

      described_class.remove! uuid: 'sekret_key'
    end

    it 'removes the session from the cache' do
      expect(Rails.cache).to have_received(:delete).with 'sekret_key'
    end
  end
end
