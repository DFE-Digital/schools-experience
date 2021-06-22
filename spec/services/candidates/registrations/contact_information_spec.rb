require 'rails_helper'

describe Candidates::Registrations::ContactInformation, type: :model do
  include_context 'Stubbed candidates school'
  it_behaves_like 'a registration step'

  context 'attributes' do
    it { is_expected.to respond_to :building }
    it { is_expected.to respond_to :street }
    it { is_expected.to respond_to :town_or_city }
    it { is_expected.to respond_to :county }
    it { is_expected.to respond_to :postcode }
    it { is_expected.to respond_to :phone }
  end

  context 'validations' do
    context 'building' do
      it { is_expected.to validate_presence_of :building }

      let(:too_long_msg) { 'Building must be 250 characters or fewer' }
      it { is_expected.to validate_length_of(:building).is_at_most(250).with_message(too_long_msg) }
    end

    context 'street' do
      let(:too_long_msg) { 'Street must be 250 characters or fewer' }

      it { is_expected.to validate_length_of(:street).is_at_most(250).with_message(too_long_msg) }
    end

    context 'town_or_city' do
      let(:too_long_msg) { 'Town or city must be 80 characters or fewer' }

      it { is_expected.to validate_length_of(:town_or_city).is_at_most(80).with_message(too_long_msg) }
    end

    context 'county' do
      let(:too_long_msg) { 'County must be 50 characters or fewer' }

      it { is_expected.to validate_length_of(:county).is_at_most(50).with_message(too_long_msg) }
    end

    context 'postcode' do
      it { is_expected.to validate_presence_of :postcode }

      let(:too_long_msg) { 'Postcode must be 20 characters or fewer' }
      it { is_expected.to validate_length_of(:postcode).is_at_most(20).with_message(too_long_msg) }
    end

    context 'phone' do
      it { is_expected.to validate_presence_of :phone }

      let(:too_long_msg) { 'Phone number must be 50 digits or fewer' }
      it { is_expected.to validate_length_of(:phone).is_at_most(50).with_message(too_long_msg) }

      context 'phone is present' do
        valid_numbers = ['01434 634996', '+441434634996', '01234567890'].freeze
        invalid_numbers = ['7', 'q', '+4414346349'].freeze
        blank_numbers = ['', ' ', '   '].freeze

        context 'valid numbers' do
          valid_numbers.each do |number|
            subject { described_class.new phone: number }
            before { subject.validate }

            it "permits #{number}" do
              expect(subject.errors[:phone]).to be_empty
            end
          end
        end

        context 'invalid numbers' do
          invalid_numbers.each do |number|
            subject { described_class.new phone: number }
            before { subject.validate }

            it "doesn't permit #{number}" do
              expect(subject.errors[:phone]).to eq ["Enter a valid telephone number"]
            end
          end
        end

        context 'blank number' do
          blank_numbers.each do |number|
            subject { described_class.new phone: number }
            before { subject.validate }

            it "doesn't permit #{number}" do
              expect(subject.errors[:phone]).to eq ["Enter your telephone number"]
            end
          end
        end
      end
    end

    context 'postcode is present' do
      let(:too_long_msg) { 'Postcode must be 20 characters or fewer' }
      it { is_expected.to validate_length_of(:postcode).is_at_most(20).with_message(too_long_msg) }

      valid_postcodes = [
        'DN55 1PT',
        'CR2 6XH',
        'B33 8TH',
        'M1 1AE',
        'W1A 0AX',
        'EC1A 1BB',
        'ch63 7ns'
      ].freeze

      invalid_postcodes = [
        'horses',
        'N0T AP057C0D3',
        'B3333 1BB',
        'CH3',
      ].freeze

      blank_postcodes = ['', ' ', '  '].freeze

      context 'valid postcodes' do
        valid_postcodes.each do |postcode|
          subject { described_class.new postcode: postcode }
          before { subject.validate }

          it "permits #{postcode}" do
            expect(subject.errors[:postcode]).to be_empty
          end
        end
      end

      context 'invalid postcodes' do
        invalid_postcodes.each do |postcode|
          subject { described_class.new postcode: postcode }
          before { subject.validate }

          it "permits #{postcode}" do
            expect(subject.errors[:postcode]).to eq ['Enter a valid postcode']
          end
        end
      end

      context 'blank postcodes' do
        blank_postcodes.each do |postcode|
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
