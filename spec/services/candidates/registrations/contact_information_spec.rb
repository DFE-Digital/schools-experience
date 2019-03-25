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
  end
end
