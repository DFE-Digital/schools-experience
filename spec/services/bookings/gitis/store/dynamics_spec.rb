require 'rails_helper'

describe Bookings::Gitis::Store::Dynamics do
  include_context 'test entity'

  let(:service_url) { 'https://my.dynamics.instance.net' }
  let(:token) { 'my.secret.token' }
  let(:dynamics) { described_class.new token, service_url: service_url }

  subject { dynamics }

  describe '.initialize' do
    it "will succeed with api object" do
      expect(described_class.new(token)).to \
        be_instance_of(Bookings::Gitis::Store::Dynamics)
    end

    it "will raise an exception without an api object" do
      expect { described_class.new }.to raise_exception(ArgumentError)
    end
  end

  describe '#find_one' do
    let(:uuid) { SecureRandom.uuid }

    context 'with match' do
      let(:attrs) { { 'testentityid' => uuid, 'firstname' => 'test' } }
      before do
        allow(dynamics.api).to receive(:get).with(
          "testentities(#{uuid})",
          '$select' => TestEntity.attributes_to_select
        ).and_return(attrs)
      end
      subject { dynamics.find_one TestEntity, uuid }
      it { is_expected.to eq TestEntity.new(attrs) }
    end

    context 'without match' do
      let(:fourohfour) do
        Bookings::Gitis::API::UnknownUrlError.new \
          OpenStruct.new(status: 404, body: "Not found", headers: {})
      end

      before do
        allow(dynamics.api).to receive(:get).with(
          "testentities(#{uuid})",
          '$select' => TestEntity.attributes_to_select
        ).and_raise(fourohfour)
      end

      it do
        expect {
          dynamics.find_one(TestEntity, uuid)
        }.to raise_exception(Bookings::Gitis::API::UnknownUrlError)
      end
    end
  end

  describe '#find_many', :focus do
    let(:uuids) do
      [
        "03ec3075-a9f9-400f-bc43-a7a5cdf68579",
        "e46fd2c9-ad04-4ebb-bc2a-26f3ad323c56",
        "2ec079dd-35a2-419a-9d01-48d63c09cdcc"
      ]
    end

    let(:matches) do
      uuids.map.with_index do |uuid, index|
        { 'testentityid' => uuid, 'firstname' => "Test #{index}" }
      end
    end

    subject { dynamics.find_many TestEntity, uuids }

    context 'with no matches' do
      before do
        allow(dynamics.api).to receive(:get).with(
          "testentities",
          '$filter' => "testentityid eq '#{uuids[0]}' or testentityid eq '#{uuids[1]}' or testentityid eq '#{uuids[2]}'",
          '$select' => TestEntity.attributes_to_select
        ).and_return('value' => [])
      end

      it { is_expected.to eq [] }
    end

    context 'with some matches' do
      before do
        allow(dynamics.api).to receive(:get).with(
          "testentities",
          '$filter' => "testentityid eq '#{uuids[0]}' or testentityid eq '#{uuids[1]}' or testentityid eq '#{uuids[2]}'",
          '$select' => TestEntity.attributes_to_select
        ).and_return('value' => matches.slice(0, 2))
      end

      it { is_expected.to all be_kind_of TestEntity }
      it { expect(subject.map(&:id)).to eq uuids.slice(0, 2) }
    end

    context 'with all matching' do
      before do
        allow(dynamics.api).to receive(:get).with(
          "testentities",
          '$filter' => "testentityid eq '#{uuids[0]}' or testentityid eq '#{uuids[1]}' or testentityid eq '#{uuids[2]}'",
          '$select' => TestEntity.attributes_to_select
        ).and_return('value' => matches)
      end

      it { is_expected.to all be_kind_of TestEntity }
      it { expect(subject.map(&:id)).to eq uuids }
    end
  end

  describe '#fetch' do
    let(:selectattrs) { TestEntity.attributes_to_select }
    let(:t1) { { 'testentityid' => SecureRandom.uuid, 'firstname' => 'A', 'lastname' => '1' } }
    let(:t2) { { 'testentityid' => SecureRandom.uuid, 'firstname' => 'B', 'lastname' => '2' } }
    let(:t3) { { 'testentityid' => SecureRandom.uuid, 'firstname' => 'C', 'lastname' => '3' } }
    let(:response) { [TestEntity.new(t1), TestEntity.new(t2), TestEntity.new(t3)] }

    context 'without entity' do
      it "will raise an error" do
        expect { subject.fetch }.to raise_exception(ArgumentError)
      end
    end

    context 'with entity and no filter' do
      before do
        expect(dynamics.api).to receive(:get).
          with('testentities', '$top' => 10, '$select' => selectattrs).
          and_return('value' => [t1, t2, t3])
      end

      subject { dynamics.fetch(TestEntity) }
      it { is_expected.to eq(response) }
    end

    context 'with entity and string filter' do
      before do
        expect(dynamics.api).to receive(:get).
          with(
            'testentities',
            '$top' => 10,
            '$select' => selectattrs,
            '$filter' => "firstname eq 'test'"
          ).
          and_return('value' => [t1, t2, t3])
      end

      subject { dynamics.fetch(TestEntity, filter: "firstname eq 'test'") }
      it { is_expected.to eq(response) }
    end

    context 'with entity and limit' do
      before do
        expect(dynamics.api).to receive(:get).
          with('testentities', '$top' => 5, '$select' => selectattrs).
          and_return('value' => [t1, t2, t3])
      end

      subject { dynamics.fetch(TestEntity, limit: 5) }
      it { is_expected.to eq(response) }
    end

    context 'with entity and order' do
      before do
        expect(dynamics.api).to receive(:get).
          with(
            'testentities',
            '$top' => 5,
            '$select' => selectattrs,
            '$orderby' => 'createdon desc'
          ).and_return('value' => [t1, t2, t3])
      end

      subject { dynamics.fetch(TestEntity, limit: 5, order: 'createdon desc') }
      it { is_expected.to eq(response) }
    end
  end

  context 'create_entity' do
    let(:uuid) { SecureRandom.uuid }

    context 'without id' do
      before do
        expect(dynamics.api).to receive(:post).with(
          '/entities', 'firstname' => 'test user'
        ).and_return('')
      end

      subject { dynamics.create_entity TestEntity.new('firstname' => 'testuser') }
      it { is_expected.to eq "entities(#{uuid})" }
    end

    context 'with id' do
      it do
        expect {
          dynamics.create_entity TestEntity.new(id: SecureRandom.uuid)
        }.to raise_exception
      end
    end

    context 'with blank id' do
      it do
        expect {
          dynamics.create_entity TestEntity.new(id: '')
        }.to raise_exception
      end
    end
  end

  context 'update_entity' do
    let(:uuid) { SecureRandom.uuid }

    context 'with id' do
      before do
        expect(dynamics.api).to receive(:patch).with(
          "/entities(#{uuid})", 'firstname' => 'test user'
        ).and_return('')
      end

      subject { dynamics.create_entity TestEntity.new('firstname' => 'testuser') }
      it { is_expected.to eq "entities(#{uuid})" }
    end

    context 'without id' do
      it do
        expect {
          dynamics.update_entity TestEntity.new(id: SecureRandom.uuid)
        }.to raise_exception
      end
    end
  end
end
