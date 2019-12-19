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

    context 'email address format' do
      VALID_EMAILS = [
        'test@example.com', 'testymctest@gmail.com',
        'test%.mctest@domain.co.uk', ' with@space.com '
      ].freeze

      INVALID_EMAILS = [
        'test.com', 'test@@test.com', 'FFFF', 'test@test',
        'test@test.'
      ].freeze

      BLANK_EMAILS = ['', ' ', '   '].freeze

      context 'primary email field' do
        BLANK_EMAILS.each do |email|
          it "will not allow email address '#{email}'" do
            is_expected.not_to allow_value(email) \
              .for(:email)
              .with_message("Enter admin contact's email address")
          end
        end
      end

      %i(email email_secondary).each do |field|
        context "email field '#{field}'" do
          VALID_EMAILS.each do |email|
            it { is_expected.to allow_value(email).for(field) }
          end

          INVALID_EMAILS.each do |email|
            it "will not allow email address '#{email}'" do
              is_expected.not_to allow_value(email) \
                .for(field)
                .with_message('Enter a valid email address')
            end
          end
        end
      end
    end
  end
end
