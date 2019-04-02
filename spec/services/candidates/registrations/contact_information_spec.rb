require 'rails_helper'

describe Candidates::Registrations::ContactInformation, type: :model do
  it_behaves_like 'a registration step'

  context 'attributes' do
    it { is_expected.to respond_to :full_name }
    it { is_expected.to respond_to :email }
    it { is_expected.to respond_to :building }
    it { is_expected.to respond_to :street }
    it { is_expected.to respond_to :town_or_city }
    it { is_expected.to respond_to :county }
    it { is_expected.to respond_to :postcode }
    it { is_expected.to respond_to :phone }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :full_name }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :building }
    it { is_expected.to validate_presence_of :postcode }
    it { is_expected.to validate_presence_of :phone }

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

    context 'phone is present' do
      VALID_NUMBERS = ['01434 634996', '+441434634996', '01234567890'].freeze
      INVALID_NUMBERS = ['7', 'q', '+4414346349'].freeze
      BLANK_NUMBERS = ['', ' ', '   '].freeze

      context 'valid numbers' do
        VALID_NUMBERS.each do |number|
          subject { described_class.new phone: number }
          before { subject.validate }

          it "permits #{number}" do
            expect(subject.errors[:phone]).to be_empty
          end
        end
      end

      context 'invalid numbers' do
        INVALID_NUMBERS.each do |number|
          subject { described_class.new phone: number }
          before { subject.validate }

          it "doesn't permit #{number}" do
            expect(subject.errors[:phone]).to eq ["Enter a valid telephone number"]
          end
        end
      end

      context 'blank number' do
        BLANK_NUMBERS.each do |number|
          subject { described_class.new phone: number }
          before { subject.validate }

          it "doesn't permit #{number}" do
            expect(subject.errors[:phone]).to eq ["Enter your telephone number"]
          end
        end
      end
    end

    context 'postcode is present' do
      VALID_POSTCODES = [
        'DN55 1PT',
        'CR2 6XH',
        'B33 8TH',
        'M1 1AE',
        'W1A 0AX',
        'EC1A 1BB',
        'ch63 7ns'
      ].freeze

      INVALID_POSTCODES = [
        'horses',
        'N0T AP057C0D3',
        'B3333 1BB'
      ].freeze

      BLANK_POSTCODES = ['', ' ', '  '].freeze

      context 'valid postcodes' do
        VALID_POSTCODES.each do |postcode|
          subject { described_class.new postcode: postcode }
          before { subject.validate }

          it "permits #{postcode}" do
            expect(subject.errors[:postcode]).to be_empty
          end
        end
      end

      context 'invalid postcodes' do
        INVALID_POSTCODES.each do |postcode|
          subject { described_class.new postcode: postcode }
          before { subject.validate }

          it "permits #{postcode}" do
            expect(subject.errors[:postcode]).to eq ['Enter a valid postcode']
          end
        end
      end

      context 'blank postcodes' do
        BLANK_POSTCODES.each do |postcode|
          subject { described_class.new postcode: postcode }
          before { subject.validate }

          it "permits #{postcode}" do
            expect(subject.errors[:postcode]).to eq ['Enter your postcode']
          end
        end
      end
    end
  end
end
