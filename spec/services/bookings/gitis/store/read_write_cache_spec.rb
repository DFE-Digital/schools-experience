require 'rails_helper'

describe Bookings::Gitis::Store::ReadWriteCache do
  class Person
    include Bookings::Gitis::Entity
    entity_id_attribute :personid
    entity_attribute :fullname
  end

  let(:version) { 'v1' }
  let(:dynamics) { Bookings::Gitis::Store::Dynamics.new 'a.fake.token' }
  let(:cache) { Rails.cache }
  let(:store) { described_class.new dynamics, cache }
  let(:uuid) { SecureRandom.uuid }
  let(:entity) { Person.new(personid: uuid, fullname: 'Test Person') }

  describe 'the Caches api' do
    subject { store }
    it_behaves_like 'an implementation of a Gitis store'
  end

  describe '#cache_key_for_uuid' do
    subject { store.cache_key_for_uuid Person, uuid }
    it { is_expected.to eql "people/#{uuid}/#{version}" }

    context 'with namespace' do
      let(:store) { described_class.new dynamics, cache, namespace: 'dynamics' }
      it { is_expected.to eql "dynamics/people/#{uuid}/#{version}" }
    end
  end

  describe '#cache_keys_for_uuids' do
    let(:second) { SecureRandom.uuid }
    let(:uuids) { [uuid, second] }
    subject { store.cache_keys_for_uuids Person, uuids }

    it { is_expected.to eql %W[people/#{uuid}/#{version} people/#{second}/#{version}] }

    context 'with namespace' do
      let(:store) { described_class.new dynamics, cache, namespace: 'dynamics' }
      it do
        is_expected.to eql \
          %W[dynamics/people/#{uuid}/#{version} dynamics/people/#{second}/#{version}]
      end
    end
  end

  describe '#find' do
    context 'with single id' do
      let(:cache_key) { store.cache_key_for_uuid Person, uuid }
      before do
        allow(dynamics).to receive(:find).and_return(entity)
        allow(cache).to receive(:read_multi).with(cache_key) do
          { cache_key => entity.to_cache }
        end
      end

      context 'not in cache' do
        before { allow(cache).to receive(:read_multi).with(cache_key) { {} } }
        subject! { store.find Person, uuid }
        it { is_expected.to be_frozen }
        it { expect(dynamics).to have_received(:find).with(Person, uuid, {}) }
        it { expect(cache).to have_received(:read_multi).with(cache_key) }
      end

      context 'in cache' do
        subject! { store.find Person, uuid }
        it { is_expected.to be_frozen }
        it { expect(dynamics).not_to have_received(:find) }
        it { expect(cache).to have_received(:read_multi).with(cache_key) }
      end

      context 'in cache but has options' do
        subject! { store.find Person, uuid, includes: :nested }
        it { is_expected.not_to be_frozen }
        it { expect(cache).not_to have_received(:read_multi) }
        it do
          expect(dynamics).to \
            have_received(:find).with(Person, uuid, includes: :nested)
        end
      end

      context 'in cache but has blank options' do
        subject! { store.find Person, uuid, includes: nil }
        it { is_expected.to be_frozen }
        it { expect(dynamics).not_to have_received(:find) }
        it { expect(cache).to have_received(:read_multi).with(cache_key) }
      end
    end

    context 'with multiple ids' do
      let(:second) { SecureRandom.uuid }
      let(:p2) { Person.new(personid: second, fullname: 'Second Person') }
      let(:uuids) { [uuid, second] }
      let(:keys) { store.cache_keys_for_uuids Person, uuids }
      before { allow(dynamics).to receive(:find) { [entity, p2] } }

      context 'non in cache' do
        before { allow(cache).to receive(:read_multi).with(*keys) { {} } }
        subject! { store.find Person, uuids }
        it { is_expected.to all be_frozen }
        it { is_expected.to match_array [entity, p2] }
        it { expect(dynamics).to have_received(:find).with(Person, uuids, {}) }
        it { expect(cache).to have_received(:read_multi).with(*keys) }
      end

      context 'some in cache' do
        before do
          allow(dynamics).to \
            receive(:find).with(Person, [entity.id], {}) { [entity] }

          allow(cache).to receive(:read_multi).with(*keys) do
            { keys[1] => p2.to_cache }
          end
        end
        subject! { store.find Person, uuids }
        it { is_expected.to all be_frozen }
        it { is_expected.to match_array [entity, p2] }
        it { expect(dynamics).to have_received(:find).with(Person, [uuid], {}) }
        it { expect(cache).to have_received(:read_multi).with(*keys) }
      end

      context 'all in cache' do
        before do
          allow(cache).to \
            receive(:read_multi).with(*keys) do
              { keys[0] => entity.to_cache, keys[1] => p2.to_cache }
            end
        end
        subject! { store.find Person, uuids }
        it { is_expected.to all be_frozen }
        it { is_expected.to match_array [entity, p2] }
        it { expect(dynamics).not_to have_received(:find) }
        it { expect(cache).to have_received(:read_multi).with(*keys) }
      end

      context 'in cache but has options' do
        before do
          allow(cache).to receive(:read_multi) do
            { keys[1] => [p2.to_cache] }
          end
        end
        subject! { store.find Person, uuids, includes: :nested }
        it { expect(subject.map(&:frozen?)).to all be false }
        it { is_expected.to match_array [entity, p2] }
        it { expect(dynamics).to have_received(:find).with(Person, uuids, includes: :nested) }
        it { expect(cache).not_to have_received(:read_multi) }
      end

      context 'in cache but has blank options' do
        before do
          allow(cache).to \
            receive(:read_multi).with(*keys) do
              { keys[0] => entity.to_cache, keys[1] => p2.to_cache }
            end
        end
        subject! { store.find Person, uuids, includes: nil }
        it { is_expected.to all be_frozen }
        it { is_expected.to match_array [entity, p2] }
        it { expect(dynamics).not_to have_received(:find) }
        it { expect(cache).to have_received(:read_multi).with(*keys) }
      end
    end
  end
end
