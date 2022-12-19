require "rails_helper"

describe Schools::PrepopulateSchoolProfile, type: :model do
  subject { instance }

  let(:first_school) { create(:bookings_school, :with_school_profile, :onboarded, name: "C school") }
  let(:second_school) { create(:bookings_school, :with_school_profile, :onboarded, name: "B school") }
  let(:third_school) { create(:bookings_school, :onboarded, name: "D school") }
  let(:fourth_school) { create(:bookings_school, name: "A school") }
  let(:user_uuid) { SecureRandom.uuid }
  let(:current_school) { third_school }
  let(:prepopulate_from_school) { second_school }
  let(:role_checked_uuids_to_urns) do
    {
      SecureRandom.uuid => first_school.urn,
      SecureRandom.uuid => second_school.urn,
      SecureRandom.uuid => third_school.urn,
      SecureRandom.uuid => fourth_school.urn,
      SecureRandom.uuid => 1_000_000
    }
  end
  let(:instance) do
    described_class.new(
      current_school,
      role_checked_uuids_to_urns,
      prepopulate_from_urn: prepopulate_from_school.urn
    )
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:any?).to(:available_schools).with_prefix }
    it { is_expected.to delegate_method(:enabled?).to(:class) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:prepopulate_from_urn) }
    it { is_expected.to validate_inclusion_of(:prepopulate_from_urn).in_array([first_school.urn, second_school.urn]) }
  end

  describe ".enabled?" do
    before do
      allow(Rails.configuration.x).to receive(:dfe_sign_in_api_enabled) { true }
      allow(Rails.configuration.x).to receive(:dfe_sign_in_api_school_change_enabled) { true }
    end

    subject { described_class }

    it { is_expected.to be_enabled }

    context "when dfe_sign_in_api_enabled is false" do
      before { allow(Rails.configuration.x).to receive(:dfe_sign_in_api_enabled) { false } }

      it { is_expected.not_to be_enabled }
    end

    context "when dfe_sign_in_api_school_change_enabled is false" do
      before { allow(Rails.configuration.x).to receive(:dfe_sign_in_api_school_change_enabled) { false } }

      it { is_expected.not_to be_enabled }
    end
  end

  describe "#available_schools" do
    subject { instance.available_schools }

    it "only returns schools which we have in our system and are onboarded, excluding the current school" do
      is_expected.to contain_exactly(first_school, second_school)
    end

    it "returns schools in alphabetical order" do
      is_expected.to eq([second_school, first_school])
    end
  end

  describe "#prepopulate!" do
    subject(:prepopulate) { instance.prepopulate! }

    it "prepopulates the school profile" do
      expect { prepopulate }.to change(current_school, :school_profile)

      excluding_attributes = %w[id bookings_school_id created_at updated_at]
      expected_attributes = prepopulate_from_school.school_profile.attributes.without(excluding_attributes)
      expect(current_school.school_profile).to have_attributes(expected_attributes)
    end
  end
end
