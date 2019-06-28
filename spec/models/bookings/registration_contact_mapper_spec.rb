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
    let(:registration) { build(:registration_session) }
    let(:contact) { Bookings::Gitis::Contact.new }
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
    it "should copy more attributes over"
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
  end
end
