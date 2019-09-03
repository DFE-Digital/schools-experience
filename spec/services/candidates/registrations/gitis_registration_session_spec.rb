require 'rails_helper'

describe Candidates::Registrations::GitisRegistrationSession do
  let(:contact) { build(:gitis_contact, :persisted) }

  let(:key) { model.model_name.param_key }
  let(:model_name) { model.model_name.element }

  shared_examples 'attributes with and without gitis data' do
    subject { registration.public_send(:"#{model_name}_attributes") }

    context 'with overridden data' do
      let(:registration) { described_class.new({ key => data }, contact) }
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
      let(:registration) { described_class.new({ key => data }, contact) }
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
    let(:gitis_data) { { 'phone' => contact.phone } }

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
    let(:gitis_data) { { 'has_dbs_check' => true } }

    describe '#background_check_attributes' do
      include_examples "attributes with and without gitis data"
    end

    describe '#background_check' do
      include_examples "model with and without gitis data"
    end
  end

  context 'Teaching Preference' do
    let(:model) { Candidates::Registrations::TeachingPreference }
    let(:data) { { 'subject_first_choice' => 'Biology', 'subject_second_choice' => 'Physics' } }
    let(:gitis_data) { { 'subject_first_choice' => 'Maths', 'subject_second_choice' => 'English' } }
    let(:school) { Bookings::School.find_by(urn: '999') || FactoryBot.create(:bookings_school, urn: '999') }

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
          described_class.new({ key => data }, contact).
            personal_information_attributes
        end

        it { is_expected.to include('first_name' => contact.firstname) }
        it { is_expected.to include('last_name' => contact.lastname) }
        it { is_expected.to include('email' => contact.email) }
        it { is_expected.to include('date_of_birth' => contact.date_of_birth) }
        it { is_expected.to include('read_only' => true) }
      end

      context 'with only gitis data' do
        subject do
          described_class.new({}, contact).personal_information_attributes
        end

        it { is_expected.to include('first_name' => contact.firstname) }
        it { is_expected.to include('last_name' => contact.lastname) }
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

        it { is_expected.to have_attributes(first_name: contact.firstname) }
        it { is_expected.to have_attributes(last_name: contact.lastname) }
        it { is_expected.to have_attributes(email: contact.email) }
        it { is_expected.to have_attributes(date_of_birth: contact.date_of_birth) }
      end

      context 'with only gitis data' do
        subject do
          described_class.new({}, contact).personal_information
        end

        it { is_expected.to have_attributes(first_name: contact.firstname) }
        it { is_expected.to have_attributes(last_name: contact.lastname) }
        it { is_expected.to have_attributes(email: contact.email) }
        it { is_expected.to have_attributes(date_of_birth: contact.date_of_birth) }
      end
    end
  end
end
