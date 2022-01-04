module Candidates
  module Registrations
    class PersonalInformation < RegistrationStep
      # multi parameter date fields aren't yet support by ActiveModel so we
      # need to include the support for them from ActiveRecord
      include ActiveRecord::AttributeAssignment

      MIN_AGE = 18
      MAX_AGE = 100

      attribute :first_name
      attribute :last_name
      attribute :email
      attribute :read_only, :boolean, default: false

      validates :first_name, presence: true, length: { maximum: 50 }, unless: :read_only
      validates :last_name, presence: true, length: { maximum: 50 }, unless: :read_only
      validates :email, presence: true, length: { maximum: 100 }
      validates :email, email_format: true, if: -> { email.present? }

      def full_name
        return nil unless first_name && last_name

        [first_name, last_name].map(&:presence).join(' ')
      end

      def issue_verification_code
        request = GetIntoTeachingApiClient::ExistingCandidateRequest.new(matchback_attributes)
        GetIntoTeachingApiClient::CandidatesApi.new.create_candidate_access_token(request)
        true
      rescue GetIntoTeachingApiClient::ApiError
        false
      end

      def first_name=(*args)
        read_only ? first_name : super
      end

      def last_name=(*args)
        read_only ? last_name : super
      end

      def email=(*args)
        if read_only
          email
        elsif args.empty? || args.first.nil?
          super
        else
          super(*([args.shift.to_s.strip] + args))
        end
      end

    private

      def matchback_attributes
        {
          email: email,
          first_name: first_name,
          last_name: last_name
        }
      end
    end
  end
end
