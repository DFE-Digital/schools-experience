require 'rails_helper'

RSpec.describe Bookings::Gitis::Entity do
  include_context 'test entity'

  subject { TestEntity.new('firstname' => 'test', 'lastname' => 'user') }

  describe ".entity_path" do
    subject { TestEntity.entity_path }
    it { is_expected.to eq('testentities') }
  end

  describe ".primary_key" do
    subject { TestEntity.primary_key }
    it { is_expected.to eq('testentityid') }
  end

  describe ".entity_attribute_names" do
    subject { TestEntity.entity_attribute_names }
    it { is_expected.to eq Set.new %w{firstname lastname hidden notcreate notupdate} }
  end

  describe "#attributes" do
    it do
      expect(subject.send(:attributes)).to \
        eq('firstname' => 'test', 'lastname' => 'user', 'testentityid' => nil)
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

  describe "private attributes" do
    it { expect(TestEntity.entity_attribute_names).to include('hidden') }
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
end
