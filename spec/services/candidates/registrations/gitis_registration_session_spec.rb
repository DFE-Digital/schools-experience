require 'rails_helper'

describe Candidates::Registrations::GitisRegistrationSession do
  let(:contact) { build(:gitis_contact, :persisted) }

  describe '#contact_information_attributes' do
    let(:data) { { 'phone' => '01111 222333' } }

    let(:key) do
      Candidates::Registrations::ContactInformation.model_name.param_key
    end

    context 'with overridden contact data' do
      subject do
        described_class.new({ key => data }, contact).
          contact_information_attributes
      end

      it { is_expected.to include(data) }
    end

    context 'with only gitis data' do
      subject do
        described_class.new({}, contact).contact_information_attributes
      end

      it { is_expected.to include('phone' => contact.phone) }
    end
  end

  describe '#contact_information' do
    let(:data) { { 'phone' => '01111 222333' } }

    let(:key) do
      Candidates::Registrations::ContactInformation.model_name.param_key
    end

    context 'with overridden contact data' do
      subject do
        described_class.new({ key => data }, contact).contact_information
      end

      it { is_expected.to have_attributes(phone: data['phone']) }
    end

    context 'with only gitis data' do
      it "will raise a missing step error" do
        expect { described_class.new({}, contact).contact_information }.to \
          raise_exception Candidates::Registrations::RegistrationSession::StepNotFound
      end
    end
  end

  describe "#personal_information_attributes" do
    let(:data) { { 'first_name' => 'Person', 'email' => 'person@personl.com' } }

    let(:key) do
      Candidates::Registrations::PersonalInformation.model_name.param_key
    end

    context 'with overridden personal data' do
      subject do
        described_class.new({ key => data }, contact).
          personal_information_attributes
      end

      it { is_expected.to include('first_name' => data['first_name']) }
      it { is_expected.to include('email' => contact.email) }
    end

    context 'with only gitis data' do
      subject do
        described_class.new({}, contact).personal_information_attributes
      end

      it { is_expected.to include('first_name' => contact.firstname) }
      it { is_expected.to include('email' => contact.email) }
    end
  end

  describe '#personal_information' do
    let(:data) { { 'first_name' => 'Person', 'email' => 'person@personl.com' } }

    let(:key) do
      Candidates::Registrations::PersonalInformation.model_name.param_key
    end

    context 'with overridden personal data' do
      subject do
        described_class.new({ key => data }, contact).personal_information
      end

      it { is_expected.to have_attributes(first_name: data['first_name']) }
      it { is_expected.to have_attributes(email: contact.email) }
    end

    context 'with only gitis data' do
      subject do
        described_class.new({}, contact).personal_information
      end

      it { is_expected.to have_attributes(first_name: contact.firstname) }
      it { is_expected.to have_attributes(email: contact.email) }
    end
  end
end
