require 'rails_helper'

RSpec.describe Bookings::RegistrationContactMapper do
  describe ".new" do
    let(:registration) { build(:registration_session) }
    let(:contact) { GetIntoTeachingApiClient::SchoolsExperienceSignUp.new }
    subject { described_class.new(registration, contact) }

    it { is_expected.to have_attributes(registration_session: registration) }
    it { is_expected.to have_attributes(gitis_contact: contact) }
  end

  describe "#registration_to_contact" do
    include_context "api latest privacy policy"
    include_context "api teaching subjects"

    let(:registration) { build(:registration_session, :with_school) }
    let(:contact) { GetIntoTeachingApiClient::SchoolsExperienceSignUp.new }
    let(:teaching_subject_id) { SecureRandom.uuid }
    let(:secondary_teaching_subject_id) { SecureRandom.uuid }
    let(:teaching_subjects) do
      [
        build(:api_lookup_item,
          id: teaching_subject_id,
          value: registration.teaching_preference.subject_first_choice),
        build(:api_lookup_item,
           id: secondary_teaching_subject_id,
           value: registration.teaching_preference.subject_second_choice),
      ]
    end
    let(:mapper) { described_class.new(registration, contact) }

    subject { mapper.registration_to_contact }

    it { is_expected.to have_attributes(first_name: registration.personal_information.first_name) }
    it { is_expected.to have_attributes(last_name: registration.personal_information.last_name) }
    it { is_expected.to have_attributes(email: registration.personal_information.email) }
    it { is_expected.to have_attributes(telephone: registration.contact_information.phone) }
    it { is_expected.to have_attributes(address_line1: registration.contact_information.building) }
    it { is_expected.to have_attributes(address_line2: registration.contact_information.street) }
    it { is_expected.to have_attributes(address_line3: "") }
    it { is_expected.to have_attributes(address_city: registration.contact_information.town_or_city) }
    it { is_expected.to have_attributes(address_state_or_province: registration.contact_information.county) }
    it { is_expected.to have_attributes(address_postcode: registration.contact_information.postcode) }
    it { is_expected.to have_attributes(has_dbs_certificate: registration.background_check.has_dbs_check) }
    it { is_expected.to have_attributes(preferred_teaching_subject_id: teaching_subject_id) }
    it { is_expected.to have_attributes(secondary_preferred_teaching_subject_id: secondary_teaching_subject_id) }
    it { is_expected.to have_attributes(accepted_policy_id: current_policy.id) }

    context "when has_dbs_certificate is changing" do
      let(:contact) do
        GetIntoTeachingApiClient::SchoolsExperienceSignUp.new(
          has_dbs_certificate: !registration.background_check.has_dbs_check
        )
      end

      it { is_expected.to have_attributes(dbs_certificate_issued_at: nil) }
    end
  end

  describe "#contact_to_personal_information" do
    let(:contact) { build(:api_schools_experience_sign_up_with_name) }
    let(:registration) { build(:registration_session) }
    let(:mapper) { described_class.new(registration, contact) }
    subject { mapper.contact_to_personal_information }

    it { is_expected.to include("first_name" => contact.first_name) }
    it { is_expected.to include("last_name" => contact.last_name) }
    it { is_expected.to include("email" => contact.email) }

    context 'with whitespace in email address' do
      let(:contact) { build(:api_schools_experience_sign_up_with_name, email: "  someone@education.gov.uk  ") }

      it "will strip the whitespace" do
        is_expected.to include("email" => "someone@education.gov.uk")
      end
    end
  end

  describe "#contact_to_contact_information" do
    let(:contact) { build(:api_schools_experience_sign_up_with_name) }
    let(:registration) { build(:registration_session) }
    let(:mapper) { described_class.new(registration, contact) }
    subject { mapper.contact_to_contact_information }

    it { is_expected.to include("phone" => contact.telephone) }
    it { is_expected.to include("building" => contact.address_line1) }
    it { is_expected.to include("street" => contact.address_line2) }
    it { is_expected.to include("town_or_city" => contact.address_city) }
    it { is_expected.to include("county" => contact.address_state_or_province) }
    it { is_expected.to include("postcode" => contact.address_postcode) }
  end

  describe "#contact_to_teaching_preference" do
    include_context "api teaching subjects"

    let(:maths) { Bookings::Subject.find_by!(name: 'Maths') }
    let(:english) { Bookings::Subject.find_by!(name: 'English') }
    let(:teaching_subjects) do
      [
        build(:api_lookup_item, value: maths.name),
        build(:api_lookup_item, value: english.name),
      ]
    end
    let(:contact) do
      build(
        :api_schools_experience_sign_up_with_name,
        preferred_teaching_subject_id: teaching_subjects.find { |subject| subject.value == "Maths" }&.id,
        secondary_preferred_teaching_subject_id: teaching_subjects.find { |subject| subject.value == "English" }&.id,
      )
    end
    let(:registration) { build(:registration_session) }
    let(:mapper) { described_class.new(registration, contact) }
    subject { mapper.contact_to_teaching_preference }

    it { is_expected.to include('subject_first_choice' => maths.name) }
    it { is_expected.to include('subject_second_choice' => english.name) }
  end
end
