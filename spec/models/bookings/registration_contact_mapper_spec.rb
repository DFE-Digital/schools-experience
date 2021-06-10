require 'rails_helper'

RSpec.describe Bookings::RegistrationContactMapper do
  describe ".new" do
    let(:registration) { build(:registration_session) }
    let(:contact) { Bookings::Gitis::Contact.new }
    subject { described_class.new(registration, contact) }

    it { is_expected.to have_attributes(registration_session: registration) }
    it { is_expected.to have_attributes(gitis_contact: contact) }
  end

  describe "#registration_to_contact" do
    let(:registration) { build(:registration_session, :with_school) }
    let(:contact) { Bookings::Gitis::Contact.new }
    let(:teachingsubjectid) do
      Bookings::Subject.find_by!(
        name: registration.teaching_preference.subject_first_choice
      ).gitis_uuid
    end
    let(:teachingsubjectid2) do
      Bookings::Subject.find_by!(
        name: registration.teaching_preference.subject_second_choice
      ).gitis_uuid
    end
    let(:mapper) { described_class.new(registration, contact) }

    subject { mapper.registration_to_contact }

    it { is_expected.to have_attributes(firstname: registration.personal_information.first_name) }
    it { is_expected.to have_attributes(lastname: registration.personal_information.last_name) }
    it { is_expected.to have_attributes(email: registration.personal_information.email) }
    it { is_expected.to have_attributes(date_of_birth: registration.personal_information.date_of_birth) }
    it { is_expected.to have_attributes(phone: registration.contact_information.phone) }
    it { is_expected.to have_attributes(building: registration.contact_information.building) }
    it { is_expected.to have_attributes(street: registration.contact_information.street) }
    it { is_expected.to have_attributes(town_or_city: registration.contact_information.town_or_city) }
    it { is_expected.to have_attributes(county: registration.contact_information.county) }
    it { is_expected.to have_attributes(postcode: registration.contact_information.postcode) }
    it { is_expected.to have_attributes(dfe_hasdbscertificate: registration.background_check.has_dbs_check) }
    it { is_expected.to have_attributes(_dfe_preferredteachingsubject01_value: teachingsubjectid) }
    it { is_expected.to have_attributes(_dfe_preferredteachingsubject02_value: teachingsubjectid2) }

    context "when contact is an instance of GetIntoTeachingApiClient::SchoolsExperienceSignUp" do
      include_context "api current privacy policy"
      include_context "api teaching subjects"

      let(:contact) { GetIntoTeachingApiClient::SchoolsExperienceSignUp.new }
      let(:teaching_subjects) do
        [
          build(:api_lookup_item,
            id: teachingsubjectid,
            value: registration.teaching_preference.subject_first_choice),
          build(:api_lookup_item,
             id: teachingsubjectid2,
             value: registration.teaching_preference.subject_second_choice),
        ]
      end

      it { is_expected.to have_attributes(first_name: registration.personal_information.first_name) }
      it { is_expected.to have_attributes(last_name: registration.personal_information.last_name) }
      it { is_expected.to have_attributes(email: registration.personal_information.email) }
      it { is_expected.to have_attributes(secondary_email: registration.personal_information.email) }
      it { is_expected.to have_attributes(date_of_birth: registration.personal_information.date_of_birth) }
      it { is_expected.to have_attributes(secondary_telephone: registration.contact_information.phone) }
      it { is_expected.to have_attributes(telephone: registration.contact_information.phone) }
      it { is_expected.to have_attributes(address_telephone: registration.contact_information.phone) }
      it { is_expected.to have_attributes(address_line1: registration.contact_information.building) }
      it { is_expected.to have_attributes(address_line2: registration.contact_information.street) }
      it { is_expected.to have_attributes(address_line3: "") }
      it { is_expected.to have_attributes(address_city: registration.contact_information.town_or_city) }
      it { is_expected.to have_attributes(address_state_or_province: registration.contact_information.county) }
      it { is_expected.to have_attributes(address_postcode: registration.contact_information.postcode) }
      it { is_expected.to have_attributes(has_dbs_certificate: registration.background_check.has_dbs_check) }
      it { is_expected.to have_attributes(preferred_teaching_subject_id: teachingsubjectid) }
      it { is_expected.to have_attributes(secondary_preferred_teaching_subject_id: teachingsubjectid2) }
      it { is_expected.to have_attributes(accepted_policy_id: current_policy.id) }

      context "when has_dbs_certificate is changing" do
        let(:contact) do
          GetIntoTeachingApiClient::SchoolsExperienceSignUp.new(
            hasDbsCertificate: !registration.background_check.has_dbs_check
          )
        end

        it { is_expected.to have_attributes(dbs_certificate_issued_at: nil) }
      end

      context "when email is already present on the contact" do
        let(:existing_email) { "existing@email.com" }
        let(:contact) { GetIntoTeachingApiClient::SchoolsExperienceSignUp.new(email: existing_email) }

        it { is_expected.to have_attributes(email: existing_email) }
      end

      context "when telephone is already present on the contact" do
        let(:existing_telephone) { "123456789" }
        let(:contact) { GetIntoTeachingApiClient::SchoolsExperienceSignUp.new(telephone: existing_telephone) }

        it { is_expected.to have_attributes(telephone: existing_telephone) }
      end

      context "when address_telephone is already present on the contact" do
        let(:existing_address_telephone) { "123456789" }
        let(:contact) { GetIntoTeachingApiClient::SchoolsExperienceSignUp.new(addressTelephone: existing_address_telephone) }

        it { is_expected.to have_attributes(address_telephone: existing_address_telephone) }
      end
    end
  end

  describe "#contact_to_personal_information" do
    let(:contact) { build(:gitis_contact, :persisted) }
    let(:registration) { build(:registration_session) }
    let(:mapper) { described_class.new(registration, contact) }
    subject { mapper.contact_to_personal_information }

    it { is_expected.to include('first_name' => contact.first_name) }
    it { is_expected.to include('last_name' => contact.last_name) }
    it { is_expected.to include('email' => contact.email) }
    it { is_expected.to include('date_of_birth' => contact.date_of_birth) }

    context 'with whitespace in email address' do
      let(:contact) do
        build(:gitis_contact, :persisted,
          emailaddress1: ' someone@education.gov.uk ',
          emailaddress2: nil)
      end

      it "will strip the whitespace" do
        is_expected.to include('email' => 'someone@education.gov.uk')
      end
    end

    context "when contact is an instance of GetIntoTeachingApiClient::SchoolsExperienceSignUp" do
      let(:contact) { build(:api_schools_experience_sign_up) }

      it { is_expected.to include("first_name" => contact.first_name) }
      it { is_expected.to include("last_name" => contact.last_name) }
      it { is_expected.to include("email" => contact.email) }
      it { is_expected.to include("date_of_birth" => contact.date_of_birth) }

      context 'with whitespace in email address' do
        let(:contact) { build(:api_schools_experience_sign_up, email: "  someone@education.gov.uk  ") }

        it "will strip the whitespace" do
          is_expected.to include("email" => "someone@education.gov.uk")
        end
      end
    end
  end

  describe "#contact_to_contact_information" do
    let(:contact) { build(:gitis_contact, :persisted) }
    let(:registration) { build(:registration_session) }
    let(:mapper) { described_class.new(registration, contact) }
    subject { mapper.contact_to_contact_information }

    it { is_expected.to include('phone' => contact.phone) }
    it { is_expected.to include('building' => contact.building) }
    it { is_expected.to include('street' => contact.street) }
    it { is_expected.to include('town_or_city' => contact.town_or_city) }
    it { is_expected.to include('county' => contact.county) }
    it { is_expected.to include('postcode' => contact.postcode) }

    context "when contact is an instance of GetIntoTeachingApiClient::SchoolsExperienceSignUp" do
      let(:contact) { build(:api_schools_experience_sign_up) }

      it { is_expected.to include("phone" => contact.secondary_telephone) }
      it { is_expected.to include("building" => contact.address_line1) }
      it { is_expected.to include("street" => "#{contact.address_line1}, #{contact.address_line2}") }
      it { is_expected.to include("town_or_city" => contact.address_city) }
      it { is_expected.to include("county" => contact.address_state_or_province) }
      it { is_expected.to include("postcode" => contact.address_postcode) }

      context "when secondary_telephone is not present" do
        let(:contact) { build(:api_schools_experience_sign_up, secondary_telephone: nil) }

        it { is_expected.to include("phone" => contact.telephone) }
      end

      context "when secondary_telephone and telephone are not present" do
        let(:contact) { build(:api_schools_experience_sign_up, secondary_telephone: nil, telephone: nil) }

        it { is_expected.to include("phone" => contact.mobile_telephone) }
      end
    end
  end

  describe "#contact_to_teaching_preference" do
    let(:maths) { Bookings::Subject.find_by!(name: 'Maths') }
    let(:english) { Bookings::Subject.find_by!(name: 'English') }
    let(:contact) do
      build :gitis_contact, :persisted,
        dfe_PreferredTeachingSubject01: maths.gitis_uuid,
        dfe_PreferredTeachingSubject02: english.gitis_uuid
    end
    let(:registration) { build(:registration_session) }
    let(:mapper) { described_class.new(registration, contact) }
    subject { mapper.contact_to_teaching_preference }

    it { is_expected.to include('subject_first_choice' => maths.name) }
    it { is_expected.to include('subject_second_choice' => english.name) }

    context "when contact is an instance of GetIntoTeachingApiClient::SchoolsExperienceSignUp" do
      include_context "api teaching subjects"

      let(:contact) do
        build(
          :api_schools_experience_sign_up,
          preferred_teaching_subject_id: maths.gitis_uuid,
          secondary_preferred_teaching_subject_id: english.gitis_uuid,
        )
      end
      let(:teaching_subjects) do
        [
          build(:api_lookup_item, id: maths.gitis_uuid, value: maths.name),
          build(:api_lookup_item, id: english.gitis_uuid, value: english.name),
        ]
      end

      it { is_expected.to include('subject_first_choice' => maths.name) }
      it { is_expected.to include('subject_second_choice' => english.name) }
    end
  end
end
