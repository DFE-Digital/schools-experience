class Candidates::VerificationCode
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  attribute :code

  validates :code, length: { is: 6 }, format: { with: /\A[0-9]*\z/ }

  before_validation if: :code do
    self.code = code.to_s.strip
  end

  def exchange(personal_information)
    return false unless valid?

    identity_data = {
      firstName: personal_information.first_name,
      lastName: personal_information.last_name,
      email: personal_information.email,
      dateOfBirth: personal_information.date_of_birth,
    }

    request = GetIntoTeachingApiClient::ExistingCandidateRequest.new(identity_data)
    api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
    api.exchange_access_token_for_schools_experience_sign_up(code, request)
  rescue GetIntoTeachingApiClient::ApiError
    errors.add(:code, :invalid)
    nil
  end
end
