module Schools
  module OnBoarding
    class AdminContact < Step
      attribute :phone, :string
      attribute :email, :string
      attribute :email2, :string

      validates :phone, presence: true
      validates :phone, phone: true, if: -> { phone.present? }
      validates :email, presence: true
      validates :email,  format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email.present? }
      validates :email2, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email2.present? }

      def self.compose(email, email2, phone)
        new email: email, email2: email2, phone: phone
      end
    end
  end
end
