module Candidates
  module Registrations
    class PersonalInformation < RegistrationStep
      # multi parameter date fields aren't yet support by AcitveModel so we
      # need to include the support for them from ActiveRecord
      include ActiveRecord::AttributeAssignment

      MIN_AGE = 18
      MAX_AGE = 100

      attribute :first_name
      attribute :last_name
      attribute :email
      attribute :date_of_birth, :date

      validates :first_name, presence: true
      validates :last_name, presence: true
      validates :email, presence: true
      validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email.present? }
      validates :date_of_birth, presence: true
      validates :date_of_birth, inclusion: { in: ->(_) { MAX_AGE.years.ago..MIN_AGE.years.ago } }, if: -> { date_of_birth.present? }

      def full_name
        return nil unless first_name && last_name

        [first_name, last_name].map(&:presence).join(' ')
      end
    end
  end
end
