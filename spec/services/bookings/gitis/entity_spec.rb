require 'rails_helper'

RSpec.describe Bookings::Gitis::Entity do
  class Stub
    include Bookings::Gitis::Entity

    attr_accessor :id
    entity_attributes :firstname, :lastname

    def initialize(data = {})
      self.firstname = data['firstname']
      self.lastname = data['lastname']
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
      expect(subject.attributes).to \
        eq('firstname' => 'test', 'lastname' => 'user')
    end
  end

  describe "#reset" do
    before { subject.reset }
    it { expect(subject.attributes).to eq({}) }
  end

  describe "#changed_attributes" do
    it "will use dirty tracking to return modified attributes since last reset" do
      expect(subject.changed_attributes).to \
        eq('firstname' => 'test', 'lastname' => 'user')

      subject.reset_dirty_attributes
      expect(subject.changed_attributes).to eq({})

      subject.lastname = 'changed'
      expect(subject.changed_attributes).to eq('lastname' => 'changed')
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
end
