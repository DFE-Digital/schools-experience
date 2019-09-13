require 'rails_helper'

describe Bookings::Gitis::ContactFuzzyMatcher, type: :model do
  describe "#find" do
    let(:contact) { build(:gitis_contact) }
    let(:date_of_birth) { Date.parse(contact.birthdate) }
    subject { described_class.new(*match_attrs).find([contact]) }

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
  end
end
