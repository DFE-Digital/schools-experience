require 'rails_helper'

describe Candidates::Registrations::PersonalInformation, type: :model do
  it_behaves_like 'a registration step'

  context 'attributes' do
    it { is_expected.to respond_to :full_name }
    it { is_expected.to respond_to :first_name }
    it { is_expected.to respond_to :last_name }
    it { is_expected.to respond_to :email }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :email }

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
  end

  describe '.create_signin_token' do
    include_context 'stubbed out Gitis'
    let(:pinfo) { build(:personal_information) }

    context 'for known candidate' do
      let(:contactid) { SecureRandom.uuid }

      before do
        gitis_stubs.stub_contact_request_by_email(pinfo.email,
          contactid: contactid)
      end

      it 'returns a token' do
        expect(pinfo.create_signin_token(gitis)).to be_present
      end
    end

    context 'for unknown candidate' do
      before do
        gitis_stubs.stub_contact_request_by_email(pinfo.email, data: [])
      end

      it 'returns false' do
        expect(pinfo.create_signin_token(gitis)).to be false
      end
    end
  end
end
