module Schools
  module OnBoarding
    class AdminContact < Step
      attribute :full_name, :string
      attribute :phone, :string
      attribute :email, :string

      validates :full_name, presence: true
      validates :phone, presence: true
      validates :phone, phone: true, if: -> { phone.present? }
      validates :email, presence: true
      validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email.present? }

      def self.compose(full_name, email, phone)
        new full_name: full_name, email: email, phone: phone
      end
    end
  end
end
