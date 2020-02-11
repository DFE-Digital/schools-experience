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

  describe '#find' do
    context 'for single id' do
      let(:uuid) { SecureRandom.uuid }

      context 'with match' do
        let(:attrs) { { 'testentityid' => uuid, 'firstname' => 'test' } }
        before do
          allow(dynamics.api).to receive(:get).with(
            "testentities(#{uuid})",
            '$select' => TestEntity.attributes_to_select,
            '$top' => 1
          ).and_return(attrs)
        end
        subject { dynamics.find TestEntity, uuid }
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
            '$select' => TestEntity.attributes_to_select,
            '$top' => 1
          ).and_raise(fourohfour)
        end

        it do
          expect {
            dynamics.find TestEntity, uuid
          }.to raise_exception(Bookings::Gitis::API::UnknownUrlError)
        end
      end

      context 'with invalid id' do
        it do
          expect { dynamics.find TestEntity, 10 }.to \
            raise_exception(ArgumentError)
        end
      end
    end

    context 'for multiple ids' do
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

      subject { dynamics.find TestEntity, uuids }

      context 'with no ids' do
        let(:uuids) { [] }
        it { is_expected.to eq [] }
      end

      context 'with no matches' do
        before do
          allow(dynamics.api).to receive(:get).with(
            "testentities",
            '$filter' => "testentityid eq '#{uuids[0]}' or testentityid eq '#{uuids[1]}' or testentityid eq '#{uuids[2]}'",
            '$select' => TestEntity.attributes_to_select,
            '$top' => 3
          ).and_return('value' => [])
        end

        it { is_expected.to eq [] }
      end

      context 'with some matches' do
        before do
          allow(dynamics.api).to receive(:get).with(
            "testentities",
            '$filter' => "testentityid eq '#{uuids[0]}' or testentityid eq '#{uuids[1]}' or testentityid eq '#{uuids[2]}'",
            '$select' => TestEntity.attributes_to_select,
            '$top' => 3
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
            '$select' => TestEntity.attributes_to_select,
            '$top' => 3
          ).and_return('value' => matches)
        end

        it { is_expected.to all be_kind_of TestEntity }
        it { expect(subject.map(&:id)).to eq uuids }
      end

      context 'with some invalid ids' do
        it do
          expect { dynamics.find TestEntity, uuids + [10] }.to \
            raise_exception(ArgumentError)
        end
      end
    end

    context 'with includes' do
      let(:companyid) { SecureRandom.uuid }
      let(:testentityid) { SecureRandom.uuid }

      let(:response) do
        {
          'teamentityid' => companyid,
          'title' => 'Human Resources',
          'leader' => {
            'testentityid' => testentityid,
            'firstname' => 'John'
          }
        }
      end

      before { allow(dynamics.api).to receive(:get).and_return(response) }

      subject! { dynamics.find(CompanyEntity, companyid, includes: :leader) }

      it "will query for the team" do
        expect(dynamics.api).to have_received(:get).with \
          "#{CompanyEntity.entity_path}(#{companyid})",
          hash_including('$expand' => 'leader')
      end

      it "will populate the team entity" do
        is_expected.to have_attributes(id: companyid, title: 'Human Resources')
      end

      it "will populate the associated leader entity" do
        expect(subject.leader).to have_attributes id: testentityid
        expect(subject.leader).to have_attributes firstname: 'John'
      end
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

  describe '#write' do
    let(:uuid) { SecureRandom.uuid }
    subject { dynamics.write entity }

    context 'for invalid entity' do
      let(:entity) { TestEntity.new('firstname' => 'testuser') }
      before { allow_any_instance_of(TestEntity).to receive(:valid?) { false } }
      it { is_expected.to be false }
    end

    context 'for new entity' do
      let(:entity) { TestEntity.new('firstname' => 'testuser') }

      before do
        expect(dynamics.api).to receive(:post).with(
          'testentities', 'firstname' => 'testuser'
        ).and_return("testentities(#{uuid})")

        subject # ensure api call happens for id assignment spec
      end

      it { is_expected.to eq uuid }
      it { expect(entity).to have_attributes id: uuid }
      it "will reset change tracking" do
        expect(entity).to have_attributes changed: []
      end
    end

    context 'for existing entity' do
      context 'with updated attributes' do
        let(:entity) do
          TestEntity.new('testentityid' => uuid).tap do |te|
            te.firstname = 'testuser'
          end
        end

        before do
          expect(dynamics.api).to receive(:patch).with(
            "testentities(#{uuid})", 'firstname' => 'testuser'
          ).and_return("testentities(#{uuid})")
        end

        it { is_expected.to eq uuid }
        it "will reset change tracking" do
          subject # subject api is called
          expect(entity).to have_attributes changed: []
        end
      end

      context 'without updated attributes' do
        let(:entity) do
          TestEntity.new('testentityid' => uuid, 'firstname' => 'testuser')
        end

        before do
          allow(dynamics.api).to receive(:patch).and_call_original
          allow(dynamics.api).to receive(:post).and_call_original
          subject # force method call
        end

        it { is_expected.to eq uuid }
        it { expect(dynamics.api).not_to have_received(:post) }
        it { expect(dynamics.api).not_to have_received(:patch) }
      end
    end
  end

  describe '#write!' do
    let(:uuid) { SecureRandom.uuid }

    context 'with valid' do
      let(:testentity) { TestEntity.new(firstname: 'Joe') }
      before { expect(dynamics).to receive(:write).and_return(uuid) }
      subject! { dynamics.write! testentity }
      it { is_expected.to eql uuid }
    end

    context 'with invalid' do
      let(:testentity) { TestEntity.new(firstname: '') }

      it "will raise an error" do
        expect { dynamics.write! testentity }.to \
          raise_exception(Bookings::Gitis::InvalidEntity) \
          .with_message('TestEntity is invalid: {:firstname=>[{:error=>:blank}]}')
      end
    end
  end
end
