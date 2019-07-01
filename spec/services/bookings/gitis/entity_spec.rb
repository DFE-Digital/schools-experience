require 'rails_helper'

RSpec.describe Bookings::Gitis::Entity do
  class Stub
    include Bookings::Gitis::Entity

    entity_id_attribute :stubid
    entity_attributes :firstname, :lastname

    def initialize(data = {})
      self.stubid = data['stubid']
      self.firstname = data['firstname']
      self.lastname = data['lastname']

      super
    end
  end

  subject { Stub.new('firstname' => 'test', 'lastname' => 'user') }

  describe ".entity_path" do
    subject { Stub.entity_path }
    it { is_expected.to eq('stubs') }
  end

  describe ".primary_key" do
    subject { Stub.primary_key }
    it { is_expected.to eq('stubid') }
  end

  describe "#attributes" do
    it do
      expect(subject.send(:attributes)).to \
        eq('firstname' => 'test', 'lastname' => 'user', 'stubid' => nil)
    end
  end

  describe "#reset" do
    before { subject.reset }
    it { expect(subject.send(:attributes)).to eq({}) }
  end

  describe '#persisted?' do
    context 'with persisted?' do
      subject { Stub.new('stubid' => SecureRandom.uuid) }
      it { is_expected.to be_persisted }
    end

    context 'with unpersisted?' do
      subject { Stub.new('firstname' => 'test') }
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
        Stub.new(
          'stubid' => SecureRandom.uuid,
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
      expect(subject).to have_attributes('entity_id' => "stubs(#{uuid})")
    end
  end

  describe "#entity_id=" do
    let(:uuid) { SecureRandom.uuid }

    context "with expected format" do
      before { subject.entity_id = "stubs(#{uuid})" }

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
    let(:stub) { Stub.new('stubid' => 10, 'firstname' => 'test', 'lastname' => 'user') }
    subject { stub.attributes_for_create }

    it { is_expected.not_to include('stubid') }
    it { is_expected.not_to include('id') }
    it { is_expected.to include('firstname' => 'test') }
    it { is_expected.to include('lastname' => 'user') }
  end

  describe "#attributes_for_update" do
    let(:stub) { Stub.new('stubid' => 10, 'firstname' => 'test', 'lastname' => 'user') }
    subject { stub.attributes_for_update }

    it { is_expected.not_to include('stubid') }
    it { is_expected.not_to include('id') }
    it { is_expected.not_to include('firstname' => 'test') }
    it { is_expected.not_to include('lastname' => 'user') }

    context 'with changes' do
      let(:stub) do
        Stub.new('stubid' => 10, 'firstname' => 'test', 'lastname' => 'user').tap do |stub|
          stub.firstname = 'changed'
          stub.lastname = 'changed'
        end
      end

      it { is_expected.not_to include('stubid') }
      it { is_expected.not_to include('id') }
      it { is_expected.to include('firstname' => 'changed') }
      it { is_expected.to include('lastname' => 'changed') }
    end
  end
end
