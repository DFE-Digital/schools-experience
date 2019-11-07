require 'rails_helper'

describe Bookings::Gitis::Store::WriteThroughCache do
  class Person
    include Bookings::Gitis::Entity
    entity_id_attribute :personid
    entity_attribute :fullname
  end

  let(:cache) { Rails.cache }
  let(:dynamics) { Bookings::Gitis::Store::Dynamics.new 'a.fake.token' }
  let(:store) { described_class.new dynamics, cache }
  let(:uuid) { SecureRandom.uuid }
  let(:entity) { Person.new(personid: uuid, fullname: 'Test Person') }

  describe 'implementation of Store api' do
    subject { store }
    it { is_expected.to respond_to :find }
    it { is_expected.to respond_to :fetch }
    it { is_expected.to respond_to :write }
  end

  describe '#cache_key_for_entity' do
    subject { store.cache_key_for_entity entity }
    it { is_expected.to eq "people/#{uuid}/v1" }

    context "with namespace" do
      let(:store) { described_class.new dynamics, cache, namespace: 'dynamics' }
      it { is_expected.to eq "dynamics/people/#{uuid}/v1" }
    end
  end

  describe '#write' do
    before { allow(cache).to receive(:delete).and_call_original }
    subject! { store.write entity }
    it { expect(cache).to have_received(:delete).with("people/#{uuid}/v1") }
  end


  it "find should push new data into cache"
  it "should check serialization is sufficiently complete"
end
