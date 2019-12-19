require 'rails_helper'

describe Schools::OnBoarding::AdminContact, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :phone }
    it { is_expected.to respond_to :email }
    it { is_expected.to respond_to :email_secondary }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :phone }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_email_format_of :email }
    it { is_expected.to validate_email_format_of :email_secondary }

    context 'phone number format' do
      subject { described_class.new(phone: phone).tap(&:validate) }

      context 'incorrect format' do
        let :phone do
          '123'
        end

        it 'is invalid' do
          expect(subject.errors[:phone]).to \
            eq ['Enter a valid UK telephone number']
        end
      end

      context 'correct format' do
        let :phone do
          '+447911 123456'
        end

        it 'is valid' do
          expect(subject.errors[:phone]).to be_empty
        end
      end

      context 'correct format with extension' do
        let :phone do
          '01234567890 ext 123'
        end

        it 'is valid' do
          expect(subject.errors[:phone]).to be_empty
        end
      end
    end
  end
end
