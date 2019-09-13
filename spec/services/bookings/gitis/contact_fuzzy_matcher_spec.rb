require 'rails_helper'

describe Bookings::Gitis::ContactFuzzyMatcher, type: :model do
  describe "#find" do
    let(:contact) { build(:gitis_contact, :persisted) }
    let(:date_of_birth) { Date.parse(contact.birthdate) }
    let(:contacts) { [contact] }
    subject { described_class.new(*match_attrs).find(contacts) }

    context 'with matching name' do
      let(:match_attrs) do
        [contact.firstname, contact.lastname, Date.parse('2000-01-01')]
      end

      it { is_expected.to eql(contact) }
    end

    context 'with all matching' do
      let(:match_attrs) { [contact.firstname, contact.lastname, date_of_birth] }
      it { is_expected.to eql(contact) }
    end

    context 'with matching dob' do
      let(:match_attrs) { ['', '', date_of_birth] }
      it { is_expected.to be_nil }
    end

    context 'with partial name match and matching dob' do
      let(:match_attrs) { ['', contact.lastname, date_of_birth] }
      it { is_expected.to eql(contact) }
    end

    context 'with matches we know about' do
      let(:second_uuid) { SecureRandom.uuid }
      let(:second) do
        build :gitis_contact, :persisted,
          contact.attributes.merge(contactid: second_uuid)
      end
      let(:contacts) { [contact, second] }
      before { create(:candidate, gitis_uuid: second_uuid) }
      let(:match_attrs) { [contact.firstname, contact.lastname, date_of_birth] }

      it { is_expected.to eql(second) }
    end
  end
end
