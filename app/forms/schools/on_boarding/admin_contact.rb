module Schools
  module OnBoarding
    class AdminContact < Step
      attribute :phone, :string
      attribute :email, :string

      validates :phone, presence: true
      validates :phone, phone: true, if: -> { phone.present? }
      validates :email, presence: true
      validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email.present? }

      def self.compose(email, phone)
        new email: email, phone: phone
      end
    end
  end
end
