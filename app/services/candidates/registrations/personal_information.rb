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
      attribute :read_only_email, :boolean, default: false

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

      def create_signin_token(gitis_crm)
        build_candidate_session(gitis_crm).create_signin_token
      end

      def email=(email_address)
        read_only_email ? email : super
      end

      # Rescue argument error thrown by
      # validates_timeliness/extensions/multiparameter_handler.rb
      # when the user enters a DOB like `-1, -1, -2`.
      # date of birth will be unset and get caught by the presence validation
      def date_of_birth=(*args)
        super
      rescue ArgumentError
        nil
      end

    private

      def build_candidate_session(gitis_crm)
        Candidates::Session.new(
          gitis_crm,
          firstname: first_name,
          lastname: last_name,
          email: email,
          date_of_birth: date_of_birth
        )
      end
    end
  end
end
