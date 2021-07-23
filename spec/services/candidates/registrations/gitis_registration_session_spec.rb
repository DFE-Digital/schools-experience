require 'rails_helper'

describe Candidates::Registrations::GitisRegistrationSession do
  let(:contact) { build(:api_schools_experience_sign_up) }

  let(:key) { model.model_name.param_key }
  let(:model_name) { model.model_name.element }
  let(:data_with_urn) { { key => data, 'urn' => '123456' } }

  shared_examples 'attributes with and without gitis data' do
    subject { registration.public_send(:"#{model_name}_attributes") }

    context 'with overridden data' do
      let(:registration) { described_class.new(data_with_urn, contact) }
      it { is_expected.to include(data) }
    end

    context 'with only gitis data' do
      let(:registration) { described_class.new({}, contact) }
      it { is_expected.to include(gitis_data) }
    end
  end

  shared_examples "model with and without gitis data" do
    subject { registration.public_send(model_name.to_sym) }

    context 'with overridden data' do
      let(:registration) { described_class.new(data_with_urn, contact) }
      it { is_expected.to have_attributes(data) }
    end

    context 'with only gitis data' do
      let(:registration) { described_class.new({}, contact) }

      it "will raise a missing step error" do
        expect { registration.public_send(model_name.to_sym) }.to \
          raise_exception Candidates::Registrations::RegistrationSession::StepNotFound
      end
    end
  end

  describe 'Contact Information' do
    let(:model) { Candidates::Registrations::ContactInformation }
    let(:data) { { 'phone' => '01111 222333' } }
    let(:gitis_data) { { 'phone' => contact.secondary_telephone } }

    describe '#contact_information_attributes' do
      include_examples "attributes with and without gitis data"
    end

    describe '#contact_information' do
      include_examples "model with and without gitis data"
    end
  end

  context 'Background Check' do
    let(:model) { Candidates::Registrations::BackgroundCheck }
    let(:data) { { 'has_dbs_check' => false } }
    let(:gitis_data) { { 'has_dbs_check' => nil } }

    describe '#background_check_attributes' do
      include_examples "attributes with and without gitis data"
    end

    describe '#background_check' do
      include_examples "model with and without gitis data"
    end
  end

  context 'Teaching Preference' do
    include_context "api teaching subjects"

    let(:model) { Candidates::Registrations::TeachingPreference }
    let(:data) { { 'subject_first_choice' => 'Biology', 'subject_second_choice' => 'Physics' } }
    let(:gitis_data) { { 'subject_first_choice' => 'Maths', 'subject_second_choice' => 'English' } }
    let(:school) { Bookings::School.find_by(urn: '999') || FactoryBot.create(:bookings_school, urn: '999') }
    let(:teaching_subjects) do
      [
        build(:api_lookup_item,
          id: contact.preferred_teaching_subject_id,
          value: "Maths"),
        build(:api_lookup_item,
           id: contact.secondary_preferred_teaching_subject_id,
           value: "English"),
      ]
    end

    before { allow(registration).to receive(:school).and_return(school) }

    describe '#teaching_preference_attributes' do
      include_examples "attributes with and without gitis data"
    end

    describe '#teaching_preference' do
      include_examples "model with and without gitis data"
    end
  end

  describe 'Personal Information' do
    let(:data) do
      {
        'first_name' => 'Person',
        'last_name' => 'A',
        'email' => 'person@personl.com',
        'date_of_birth' => Date.parse('1970-01-01')
      }
    end

    let(:model) { Candidates::Registrations::PersonalInformation }

    describe "#personal_information_attributes" do
      context 'with overridden personal data' do
        subject do
          described_class.new({ key => data }, contact)
            .personal_information_attributes
        end

        it { is_expected.to include('first_name' => contact.first_name) }
        it { is_expected.to include('last_name' => contact.last_name) }
        it { is_expected.to include('email' => contact.email) }
        it { is_expected.to include('date_of_birth' => contact.date_of_birth) }
        it { is_expected.to include('read_only' => true) }

        context 'with some blank fields in gitis data' do
          let(:contact) do
            build :api_schools_experience_sign_up,
              date_of_birth: nil,
              first_name: " ",
              last_name: " "
          end

          it { is_expected.to include('first_name' => data['first_name']) }
          it { is_expected.to include('last_name' => data['last_name']) }
          it { is_expected.to include('email' => contact.email) }
          it { is_expected.to include('date_of_birth' => data['date_of_birth']) }
          it { is_expected.to include('read_only' => true) }
        end
      end

      context 'with only gitis data' do
        subject do
          described_class.new({}, contact).personal_information_attributes
        end

        it { is_expected.to include('first_name' => contact.first_name) }
        it { is_expected.to include('last_name' => contact.last_name) }
        it { is_expected.to include('email' => contact.email) }
        it { is_expected.to include('date_of_birth' => contact.date_of_birth) }
        it { is_expected.to include('read_only' => true) }
      end
    end

    describe '#personal_information' do
      context 'with overridden personal data' do
        subject do
          described_class.new({ key => data }, contact).personal_information
        end

        it { is_expected.to have_attributes(first_name: contact.first_name) }
        it { is_expected.to have_attributes(last_name: contact.last_name) }
        it { is_expected.to have_attributes(email: contact.email) }
        it { is_expected.to have_attributes(date_of_birth: contact.date_of_birth) }

        context 'with some blank fields in gitis data' do
          let(:contact) do
            build :gitis_contact, :persisted,
              date_of_birth: nil,
              first_name: "",
              last_name: ""
          end

          it { is_expected.to be_valid }
          it { is_expected.to have_attributes(first_name: data['first_name']) }
          it { is_expected.to have_attributes(last_name: data['last_name']) }
          it { is_expected.to have_attributes(email: contact.email) }
          it { is_expected.to have_attributes(date_of_birth: data['date_of_birth']) }
        end
      end

      context 'with only gitis data' do
        subject do
          described_class.new({}, contact).personal_information
        end

        it { is_expected.to have_attributes(first_name: contact.first_name) }
        it { is_expected.to have_attributes(last_name: contact.last_name) }
        it { is_expected.to have_attributes(email: contact.email) }
        it { is_expected.to have_attributes(date_of_birth: contact.date_of_birth) }
      end
    end
  end
end
