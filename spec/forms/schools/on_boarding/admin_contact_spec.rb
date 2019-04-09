require 'rails_helper'

describe Schools::OnBoarding::AdminContact, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :full_name }
    it { is_expected.to respond_to :phone }
    it { is_expected.to respond_to :email }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :full_name }
    it { is_expected.to validate_presence_of :phone }
    it { is_expected.to validate_presence_of :email }

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
    end

    context 'email address format' do
      subject { described_class.new(email: email).tap(&:validate) }

      context 'incorrect format' do
        let :email do
          'test@'
        end

        it 'is invalid' do
          expect(subject.errors[:email]).to eq ['Enter a valid email address']
        end
      end

      context 'correct format' do
        let :email do
          'test@example.com'
        end

        it 'is valid' do
          expect(subject.errors[:email]).to be_empty
        end
      end
    end
  end
end
