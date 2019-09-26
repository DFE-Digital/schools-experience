require 'rails_helper'

describe Candidates::Registrations::PersonalInformation, type: :model do
  it_behaves_like 'a registration step'

  context 'attributes' do
    it { is_expected.to respond_to :full_name }
    it { is_expected.to respond_to :first_name }
    it { is_expected.to respond_to :last_name }
    it { is_expected.to respond_to :email }
    it { is_expected.to respond_to :read_only }
    it { is_expected.to have_attributes read_only: false }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :date_of_birth }

    let(:too_long_msg) { 'Email must be 100 characters or fewer' }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_length_of(:email).is_at_most(100).with_message(too_long_msg) }

    context 'when read only' do
      subject { described_class.new read_only: true }
      it { is_expected.not_to validate_presence_of :first_name }
      it { is_expected.not_to validate_presence_of :last_name }
      it { is_expected.to validate_presence_of :email }
      it { is_expected.not_to validate_presence_of :date_of_birth }
    end

    context 'email is present' do
      VALID_EMAILS = ['test@example.com', 'testymctest@gmail.com'].freeze
      INVALID_EMAILS = ['test.com', 'test@@test.com', 'FFFF'].freeze
      BLANK_EMAILS = ['', ' ', '   '].freeze

      context 'valid emails' do
        VALID_EMAILS.each do |email|
          subject { described_class.new email: email }
          before { subject.validate }

          it "permits #{email}" do
            expect(subject.errors[:email]).to be_empty
          end
        end
      end

      context 'invalid emails' do
        INVALID_EMAILS.each do |email|
          subject { described_class.new email: email }
          before { subject.validate }

          it "doesn't permit #{email}" do
            expect(subject.errors[:email]).to eq ['Enter a valid email address']
          end
        end
      end

      context 'blank emails' do
        BLANK_EMAILS.each do |email|
          subject { described_class.new email: email }
          before { subject.validate }

          it "doesn't permit #{email}" do
            expect(subject.errors[:email]).to eq ['Enter your email address']
          end
        end
      end
    end
  end

  context '#full_name' do
    context 'when first_name last_name attributes are set' do
      subject { described_class.new first_name: 'Testy', last_name: 'McTest' }

      it 'returns combined first_name last_name' do
        expect(subject.full_name).to eq 'Testy McTest'
      end
    end

    context 'when first_name last_name attributes are not set' do
      context 'when full_name is not set' do
        subject { described_class.new }

        it 'returns nil' do
          expect(subject.full_name).to eq nil
        end
      end

      context 'when full_name is set' do
        subject { described_class.new first_name: 'Testy', last_name: 'McTest' }

        it 'returns the value for the full_name attribute' do
          expect(subject.full_name).to eq 'Testy McTest'
        end
      end
    end

    context '#date_of_birth' do
      subject { described_class.new date_of_birth: date_of_birth }

      before do
        subject.validate
      end

      context 'too young' do
        let :date_of_birth do
          18.years.ago + 1.day
        end

        it 'is invalid' do
          expect(subject.errors[:date_of_birth]).to eq [
            'Enter a valid date of birth. You must be at least 18 years old'
          ]
        end
      end

      context 'too old' do
        let :date_of_birth do
          100.years.ago
        end

        it 'is invalid' do
          expect(subject.errors[:date_of_birth]).to eq [
            'Enter a valid date of birth. You must be at least 18 years old'
          ]
        end
      end

      context 'out of range' do
        let :date_of_birth do
          { 3 => -1, 2 => -1, 1 => -2 }
        end

        it 'is invalid' do
          expect(subject.errors[:date_of_birth]).to eq [
            'Enter your date of birth'
          ]
        end
      end

      context 'valid' do
        let :date_of_birth do
          25.years.ago
        end

        it 'is valid' do
          expect(subject.errors[:date_of_birth]).to be_empty
        end
      end
    end
  end

  describe '.create_signin_token' do
    include_context 'stubbed out Gitis'
    let(:pinfo) { build(:personal_information) }

    context 'for known candidate' do
      let(:contactid) { SecureRandom.uuid }

      before do
        gitis_stubs.stub_contact_signin_request(pinfo.email, contactid => {
          firstname: pinfo.first_name,
          lastname: pinfo.last_name
        })
      end

      it 'returns a token' do
        expect(pinfo.create_signin_token(gitis)).to be_present
      end
    end

    context 'for unknown candidate' do
      before do
        gitis_stubs.stub_contact_signin_request(pinfo.email, [])
      end

      it 'returns false' do
        expect(pinfo.create_signin_token(gitis)).to be false
      end
    end
  end

  describe 'with read_only set to true' do
    let(:pinfo) { described_class.new(read_only: true) }

    before do
      pinfo.assign_attributes \
        first_name: 'test',
        last_name: 'test',
        email: 'test@test.com',
        date_of_birth: Date.parse('1980-01-01')
    end

    subject { pinfo }

    it { is_expected.to have_attributes first_name: nil }
    it { is_expected.to have_attributes last_name: nil }
    it { is_expected.to have_attributes email: nil }
    it { is_expected.to have_attributes date_of_birth: nil }
  end
end
