require 'rails_helper'

describe Bookings::Gitis::Store::WriteOnlyCache do
  class Person
    include Bookings::Gitis::Entity
    entity_id_attribute :personid
    entity_attribute :fullname
  end

  let(:version) { 'v1' }
  let(:ttl) { 1.hour }
  let(:cache) { Rails.cache }
  let(:dynamics) { Bookings::Gitis::Store::Dynamics.new 'a.fake.token' }
  let(:store) { described_class.new dynamics, cache }
  let(:uuid) { SecureRandom.uuid }
  let(:entity) { Person.new(personid: uuid, fullname: 'Test Person') }

  describe 'an implementation of Store api' do
    subject { store }
    it { is_expected.to respond_to :find }
    it { is_expected.to respond_to :fetch }
    it { is_expected.to respond_to :write }
  end

  describe '#cache_key_for_entity' do
    subject { store.cache_key_for_entity entity }
    it { is_expected.to eq "people/#{uuid}/#{version}" }

    context "with namespace" do
      let(:store) { described_class.new dynamics, cache, namespace: 'dynamics' }
      it { is_expected.to eq "dynamics/people/#{uuid}/#{version}" }
    end
  end

  describe '#write' do
    before { allow(cache).to receive(:delete).and_call_original }
    subject! { store.write entity }
    it { expect(cache).to have_received(:delete).with("people/#{uuid}/#{version}") }
  end

  describe '#find' do
    let(:key) { "people/#{uuid}/#{version}" }
    before { allow(cache).to receive(:write_multi).and_call_original }

    context 'with single id' do
      context 'without any options' do
        before do
          allow(dynamics).to receive(:find).with(Person, uuid, {}) { entity }
        end

        subject! { store.find Person, uuid }

        it { is_expected.to eql entity }

        it do
          expect(cache).to \
            have_received(:write_multi).
              with({ key => entity.to_cache }, expires_in: ttl)
        end
      end

      context 'with options' do
        before do
          allow(dynamics).to \
            receive(:find).with(Person, uuid, includes: :nested) { entity }
        end

        subject! { store.find Person, uuid, includes: :nested }

        it { is_expected.to eql entity }
        it { expect(cache).not_to have_received(:write_multi) }
      end
    end

    context 'with multiple ids' do
      let(:second) { SecureRandom.uuid }
      let(:uuids) { [uuid, second] }

      context 'without any options' do
        before do
          allow(dynamics).to receive(:find).with(Person, uuids, {}) { [entity] }
        end

        subject! { store.find Person, uuids }

        it { is_expected.to eql [entity] }

        it do
          expect(cache).to \
            have_received(:write_multi).
              with({ key => entity.to_cache }, expires_in: ttl)
        end
      end

      context 'with options' do
        before do
          allow(dynamics).to \
            receive(:find).with(Person, uuids, includes: :nested) { [entity] }
        end

        subject! { store.find Person, uuids, includes: :nested }

        it { is_expected.to eql [entity] }
        it { expect(cache).not_to have_received(:write_multi) }
      end
    end
  end
end
