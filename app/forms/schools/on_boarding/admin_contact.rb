module Schools
  module OnBoarding
    class AdminContact < Step
      include ActiveModel::Validations::Callbacks

      attribute :phone, :string
      attribute :email, :string
      attribute :email_secondary, :string

      validates :phone, presence: true
      validates :phone, phone: true, if: -> { phone.present? }
      validates :email, presence: true
      validates :email, email_format: true, if: -> { email.present? }
      validates :email_secondary, email_format: true, if: -> { email_secondary.present? }

      before_validation(if: :email) { self.email = email.strip }
      before_validation(if: :email_secondary) { self.email_secondary = email_secondary.strip }

      def self.compose(email, email_secondary, phone)
        new email: email, email_secondary: email_secondary, phone: phone
      end
    end
  end
end
