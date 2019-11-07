require 'rails_helper'

RSpec.describe Bookings::Gitis::Entity do
  include_context 'test entity'

  subject { TestEntity.new('firstname' => 'test', 'lastname' => 'user') }

  let(:expected_attrs) { %w{firstname lastname hidden notcreate notupdate} }

  it { is_expected.to have_attributes entity_path: 'testentities' }
  it { is_expected.to have_attributes primary_key: 'testentityid' }
  it { is_expected.to have_attributes select_attribute_names: Set.new(expected_attrs) }
  it { is_expected.to have_attributes attributes_to_select: expected_attrs.join(',') }

  describe "#attributes" do
    it do
      expect(subject.send(:attributes)).to \
        eq('firstname' => 'test', 'lastname' => 'user')
    end
  end

  describe "#reset" do
    before { subject.reset }
    it { expect(subject.send(:attributes)).to eq({}) }
  end

  describe '#persisted?' do
    context 'with persisted?' do
      subject { TestEntity.new('testentityid' => SecureRandom.uuid) }
      it { is_expected.to be_persisted }
    end

    context 'with unpersisted?' do
      subject { TestEntity.new('firstname' => 'test') }
      it { is_expected.not_to be_persisted }
    end
  end

  describe "#changed_attributes" do
    context 'for unpersisted object' do
      it "will use dirty tracking to return modified attributes since last reset" do
        expect(subject.changed_attributes).to \
          eq('firstname' => 'test', 'lastname' => 'user')

        subject.reset_dirty_attributes
        expect(subject.changed_attributes).to eq({})

        subject.lastname = 'changed'
        expect(subject.changed_attributes).to eq('lastname' => 'changed')
      end
    end

    context 'for persisted object' do
      subject do
        TestEntity.new(
          'testentityid' => SecureRandom.uuid,
          'firstname' => 'Test',
          'lastname' => 'User'
        )
      end

      it "will not have any changed attributes" do
        expect(subject.changed_attributes).to eq({})
      end

      context 'with changed name' do
        before { subject.firstname = 'Changed' }

        it "will include name" do
          expect(subject.changed_attributes).to eq('firstname' => 'Changed')
        end
      end
    end
  end

  describe "#entity_id" do
    let(:uuid) { SecureRandom.uuid }
    before { subject.id = uuid }

    it "will include uuid and entity_path" do
      expect(subject).to have_attributes('entity_id' => "testentities(#{uuid})")
    end
  end

  describe "#entity_id=" do
    let(:uuid) { SecureRandom.uuid }

    context "with expected format" do
      before { subject.entity_id = "testentities(#{uuid})" }

      it "will set the id" do
        expect(subject.id).to eq(uuid)
      end
    end

    context "with unexpected format" do
      it "will raise" do
        expect { subject.entity_id = uuid }.to \
          raise_exception(Bookings::Gitis::Entity::InvalidEntityIdError)
      end
    end

    context "with nil" do
      it "will raise" do
        expect { subject.entity_id = nil }.to \
          raise_exception(Bookings::Gitis::Entity::InvalidEntityIdError)
      end
    end
  end

  describe "#attributes_for_create" do
    let(:entity) { TestEntity.new('testentityid' => 10, 'firstname' => 'test', 'lastname' => 'user') }
    subject { entity.attributes_for_create }

    it { is_expected.not_to include('testentityid') }
    it { is_expected.not_to include('id') }
    it { is_expected.to include('firstname' => 'test') }
    it { is_expected.to include('lastname' => 'user') }
  end

  describe "#attributes_for_update" do
    let(:entity) { TestEntity.new('testentityid' => 10, 'firstname' => 'test', 'lastname' => 'user') }
    subject { entity.attributes_for_update }

    it { is_expected.not_to include('testentityid') }
    it { is_expected.not_to include('id') }
    it { is_expected.not_to include('firstname' => 'test') }
    it { is_expected.not_to include('lastname' => 'user') }

    context 'with changes' do
      let(:entity) do
        TestEntity.new('testentityid' => 10, 'firstname' => 'test', 'lastname' => 'user').tap do |entity|
          entity.firstname = 'changed'
          entity.lastname = 'changed'
        end
      end

      it { is_expected.not_to include('testentityid') }
      it { is_expected.not_to include('id') }
      it { is_expected.to include('firstname' => 'changed') }
      it { is_expected.to include('lastname' => 'changed') }
    end
  end

  describe "caching" do
    let(:uuid) { SecureRandom.uuid }
    let(:entity) { TestEntity.new 'testentityid' => uuid, 'firstname' => 'test' }

    describe '#cache_key' do
      subject { entity }
      it { is_expected.to have_attributes cache_key: "testentities/#{uuid}" }
    end

    describe "#to_cache" do
      before { entity.tap { |te| te.lastname = 'mctest' } }
      subject { entity.to_cache }
      it { is_expected.to include('testentityid' => uuid) }
      it { is_expected.to include('firstname' => 'test') }
      it { is_expected.not_to include('lastname') }
    end

    describe ".from_cache" do
      let(:attrs) { { 'testentityid' => uuid, 'firstname' => 'test' } }
      subject { TestEntity.from_cache attrs }
      it { is_expected.to have_attributes testentityid: uuid }
      it { is_expected.to have_attributes firstname: 'test' }
      it { is_expected.to be_frozen }
    end
  end

  describe '#==' do
    let(:entity) { TestEntity.new('testentityid' => 10, 'firstname' => 'test', 'lastname' => 'user') }

    context 'with matching id' do
      let(:e2) { TestEntity.new('testentityid' => 10, 'firstname' => 'x', 'lastname' => 'y') }
      it { expect(entity == e2).to be true }
    end

    context 'with matching attributes but different id' do
      let(:e2) { TestEntity.new('testentityid' => 1, 'firstname' => 'test', 'lastname' => 'user') }
      it { expect(entity == e2).to be false }
    end
  end

  describe "private attributes" do
    it { expect(TestEntity.select_attribute_names).to include('hidden') }
    it { expect(TestEntity.respond_to?('hidden')).to be false }
    it { expect(TestEntity.respond_to?('hidden=')).to be false }
  end

  describe "exclude: :create attributes" do
    subject { TestEntity.new.tap { |s| s.notcreate = 'test' } }
    it { expect(subject.attributes_for_create).not_to include('notcreate' => 'test') }
    it { expect(subject.attributes_for_update).to include('notcreate' => 'test') }
  end

  describe "exclude: :update attributes" do
    subject { TestEntity.new.tap { |s| s.notupdate = 'test' } }
    it { expect(subject.attributes_for_create).to include('notupdate' => 'test') }
    it { expect(subject.attributes_for_update).not_to include('notupdate' => 'test') }
  end

  describe '.entity_association' do
    let(:testentity) do
      TestEntity.new('testentityid' => SecureRandom.uuid, 'firstname' => 'test')
    end

    class Associated
      include Bookings::Gitis::Entity

      entity_id_attribute :associatedid
      entity_attribute :description
      entity_association :testassoc, TestEntity

      def initialize(crmdata = {})
        self.associatedid = crmdata['associatedid']
        self.description = crmdata['description']
        self._testassoc_value = crmdata['_testassoc_value']

        super
      end
    end

    context 'with new instance' do
      subject { Associated.new('description' => 'test') }

      it { is_expected.to have_attributes _testassoc_value: nil }

      it "is excluded from attributes_for_create" do
        expect(subject.attributes_for_create).not_to \
          include('testassoc@odata.bind')
      end

      context "and assigned via value variant" do
        before { subject._testassoc_value = testentity.id }

        it { is_expected.to have_attributes _testassoc_value: testentity.id }

        it "is included in create attributes" do
          expect(subject.attributes_for_create).to \
            include('testassoc@odata.bind' => testentity.entity_id)
        end
      end

      context "and assigned via attribute itself" do
        before { subject.testassoc = testentity.id }

        it { is_expected.to have_attributes _testassoc_value: testentity.id }

        it "is included in create attributes" do
          expect(subject.attributes_for_create).to \
            include('testassoc@odata.bind' => testentity.entity_id)
        end
      end

      context "and assigned via associating a class" do
        before { subject.testassoc = testentity }

        it { is_expected.to have_attributes _testassoc_value: testentity.id }

        it "is included in create attributes" do
          expect(subject.attributes_for_create).to \
            include('testassoc@odata.bind' => testentity.entity_id)
        end
      end
    end

    context 'with existing instance' do
      let(:e2) do
        TestEntity.new('testentityid' => SecureRandom.uuid, 'firstname' => 'second')
      end

      subject do
        Associated.new(
          'associatedid' => SecureRandom.uuid,
          'description' => 'test',
          '_testassoc_value' => testentity.id
        )
      end

      it { is_expected.to have_attributes _testassoc_value: testentity.id }

      it "is excluded from attributes_for_update" do
        expect(subject.attributes_for_update).not_to \
          include('testassoc@odata.bind')
      end

      context "and assigned via value variant" do
        before { subject._testassoc_value = e2.id }

        it { is_expected.to have_attributes _testassoc_value: e2.id }

        it "is included in update attributes" do
          expect(subject.attributes_for_update).to \
            include('testassoc@odata.bind' => e2.entity_id)
        end
      end

      context "and assigned via attribute with a hash" do
        before { subject.testassoc = e2.attributes }

        it { is_expected.to have_attributes _testassoc_value: e2.id }
        it { expect(subject.testassoc).to have_attributes id: e2.id }
        it { expect(subject.testassoc).to have_attributes firstname: e2.firstname }

        it "is included in update attributes" do
          expect(subject.attributes_for_update).to \
            include('testassoc@odata.bind' => e2.entity_id)
        end
      end

      context "and assigned via attribute with a class" do
        before { subject.testassoc = e2 }

        it { is_expected.to have_attributes _testassoc_value: e2.id }
        it { expect(subject.testassoc).to have_attributes id: e2.id }
        it { expect(subject.testassoc).to have_attributes firstname: e2.firstname }

        it "is included in update attributes" do
          expect(subject.attributes_for_update).to \
            include('testassoc@odata.bind' => e2.entity_id)
        end
      end
    end

    context 'initializing with existing data' do
      let(:companyid) { SecureRandom.uuid }
      let(:testid) { SecureRandom.uuid }

      subject do
        CompanyEntity.new \
          'teamentityid' => companyid,
          'title' => 'HR',
          'leader' => { 'testentityid' => testid, 'firstname' => 'John' },
          '_leader_value' => testid
      end

      it { is_expected.to have_attributes _leader_value: testid }
      it { is_expected.to have_attributes title: 'HR' }
      it { expect(subject.leader).to have_attributes testentityid: testid }
      it { expect(subject.leader).to have_attributes firstname: 'John' }
    end
  end

  describe '.entity_collection' do
    class TeamEntity
      include Bookings::Gitis::Entity

      entity_attribute :name
      entity_collection :players, TestEntity
    end

    context 'initializing with data' do
      let(:player1) { SecureRandom.uuid }
      let(:player2) { SecureRandom.uuid }
      let(:player3) { SecureRandom.uuid }

      let(:crmdata) do
        {
          'name' => 'Manchester Sevens',
          'players' => [
            { 'testentityid' => player1, 'firstname' => 'Jane' },
            { 'testentityid' => player2, 'firstname' => 'John' },
            { 'testentityid' => player3, 'firstname' => 'Joe' }
          ]
        }
      end

      subject { TeamEntity.new(crmdata) }

      it { is_expected.to have_attributes name: 'Manchester Sevens' }
      it { expect(subject.players).to have_attributes length: 3 }
      it { expect(subject.players).to all be_kind_of TestEntity }

      it do
        expect(subject.players[0]).to have_attributes \
          testentityid: player1, firstname: 'Jane'
      end

      it do
        expect(subject.players[1]).to have_attributes \
          testentityid: player2, firstname: 'John'
      end

      it do
        expect(subject.players[2]).to have_attributes \
          testentityid: player3, firstname: 'Joe'
      end
    end
  end

  describe '.valid_id?' do
    context 'for valid uuid' do
      subject { described_class.valid_id? SecureRandom.uuid }
      it { is_expected.to be true }
    end

    context 'for valid uuid' do
      subject { described_class.valid_id? '10' }
      it { is_expected.to be false }
    end
  end
end
