require 'rails_helper'

describe Bookings::Gitis::ContactFuzzyMatcher, type: :model do
  describe "#find" do
    let(:contact) { build(:gitis_contact, :persisted) }
    let(:date_of_birth) { Date.parse(contact.birthdate) }
    let(:contacts) { [contact] }

    let(:second_uuid) { SecureRandom.uuid }
    let(:second_attrs) { contact.attributes.merge(contactid: second_uuid) }
    let(:second) { build :gitis_contact, :persisted, second_attrs }

    let(:third_uuid) { SecureRandom.uuid }
    let(:third_attrs) { contact.attributes.merge(contactid: third_uuid) }
    let(:third) { build :gitis_contact, :persisted, third_attrs }

    subject { described_class.new(*match_attrs).find(contacts) }

    context 'with matching name' do
      let(:match_attrs) do
        [contact.firstname, contact.lastname, Date.parse('2000-01-01')]
      end

      it { is_expected.to eql contact }
    end

    context 'with all matching' do
      let(:match_attrs) { [contact.firstname, contact.lastname, date_of_birth] }
      it { is_expected.to eql contact }
    end

    context 'with matching dob' do
      let(:match_attrs) { ['', '', date_of_birth] }
      it { is_expected.to be_nil }
    end

    context 'with partial name match and matching dob' do
      let(:match_attrs) { ['', contact.lastname, date_of_birth] }
      it { is_expected.to eql contact }
    end

    context 'with multiple' do
      let(:match_attrs) { [contact.firstname, contact.lastname, date_of_birth] }
      let(:contacts) { [third, second, contact] }

      it "will choose latest" do
        is_expected.to eql third
      end

      context 'and latest doesnt match' do
        let(:third_attrs) do
          contact.attributes.merge \
            contactid: third_uuid,
            firstname: 'ignore',
            lastname: 'ignore'
        end

        it "will choose latest matching" do
          is_expected.to eql second
        end
      end
    end

    context 'with matches we know about' do
      let(:contacts) { [contact, second] }
      let(:match_attrs) { [contact.firstname, contact.lastname, date_of_birth] }

      before { create(:candidate, gitis_uuid: second_uuid) }

      it { is_expected.to eql(second) }
    end

    context 'with multiple matches we already know about' do
      let(:contacts) { [third, second, contact] }
      let(:match_attrs) { [contact.firstname, contact.lastname, date_of_birth] }

      before { create(:candidate, gitis_uuid: second_uuid) }
      before { create(:candidate, gitis_uuid: contact.contactid) }

      it { is_expected.to eql(second) }
    end
  end
end
