require "rails_helper"

RSpec.describe User, type: :model do
  let(:attributes) do
    [
      {
        sub: "abc-123",
        given_name: "John",
        family_name: "Doe",
      },
      {
        sub: "def-456",
        given_name: "Jane",
        family_name: "Smith",
      }
    ]
  end

  it { is_expected.to respond_to(:has_role?) }

  describe ".exchange" do
    let(:first_attributes) { attributes.first }

    subject(:exchange) { described_class.exchange(first_attributes) }

    it { expect { exchange }.to change(described_class, :count).by(1) }
    it do
      is_expected.to have_attributes(first_attributes)
    end

    context "when the user already exists" do
      before { create(:user, sub: first_attributes[:sub]) }

      it { expect { exchange }.not_to change(described_class, :count) }
    end

    context "when there are unknown attributes" do
      let(:first_attributes) { { sub: "abc-123", unknown: :other } }

      it { is_expected.to have_attributes(first_attributes.slice(:sub)) }
    end
  end

  describe ".exchange_all" do
    let(:keyed_attributes) { attributes.index_by { |a| a[:sub] } }

    subject(:exchange_all) { described_class.exchange_all(keyed_attributes) }

    it { expect { exchange_all }.to change(described_class, :count).by(attributes.count) }

    it "creates users and assigns attributes" do
      exchange_all.each.with_index do |user, idx|
        expect(user.attributes.symbolize_keys).to include(attributes[idx])
      end
    end

    context "when the users already exists" do
      before { attributes.each { |a| create(:user, sub: a[:sub]) } }

      it { expect { exchange_all }.not_to change(described_class, :count) }
    end

    context "when there are unknown attributes" do
      let(:attributes) { [{ sub: "abc-123", unknown: :other }, { sub: "def-456", unknown: :other }] }

      it "creates users, ignoring unknown attributes" do
        exchange_all.each.with_index do |user, idx|
          expect(user.attributes.symbolize_keys).to include(attributes[idx].slice(:sub))
        end
      end
    end
  end

  describe ".find_or_create_by_subs" do
    let(:subs) { attributes.map { |a| a[:sub] } }

    subject(:find_or_create_by_subs) { described_class.find_or_create_by_subs(subs) }

    it { expect { find_or_create_by_subs }.to change(described_class, :count).by(subs.count) }

    context "when a user with the sub already exists" do
      before { create(:user, sub: attributes.first[:sub]) }

      it { expect { find_or_create_by_subs }.to change(described_class, :count).by(attributes.count - 1) }
    end
  end

  describe ".trim_unknown_attributes" do
    let(:attributes) do
      {
        sub: "33333333-4444-5555-6666-777777777777",
        unknown: "other",
      }
    end

    subject { described_class.trim_unknown_attributes(attributes) }

    it { is_expected.to eq(attributes.slice(:sub)) }
  end
end
