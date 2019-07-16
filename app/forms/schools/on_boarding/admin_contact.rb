module Schools
  module OnBoarding
    class AdminContact < Step
      attribute :phone, :string
      attribute :email, :string
      attribute :email_secondary, :string

      validates :phone, presence: true
      validates :phone, phone: true, if: -> { phone.present? }
      validates :email, presence: true
      validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email.present? }
      validates :email_secondary, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email_secondary.present? }

      def self.compose(email, email_secondary, phone)
        new email: email, email_secondary: email_secondary, phone: phone
      end
    end
  end
end
