class Candidates::VerificationCode
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks
  include ActiveRecord::AttributeAssignment

  attribute :code, :string
  # Will be pre-validated by another model.
  attribute :email, :string
  attribute :firstname, :string
  attribute :lastname, :string
  attribute :date_of_birth, :date

  validates :code, length: { is: 6 }, format: { with: /\A[0-9]*\z/ }

  before_validation if: :code do
    self.code = code.to_s.strip
  end

  def issue_verification_code
    request = GetIntoTeachingApiClient::ExistingCandidateRequest.new(matchback_attributes)
    GetIntoTeachingApiClient::CandidatesApi.new.create_candidate_access_token(request)
    true
  rescue GetIntoTeachingApiClient::ApiError
    false
  end

  def exchange
    return false unless valid?

    identity_data = {
      firstName: firstname,
      lastName: lastname,
      email: email,
      dateOfBirth: date_of_birth,
    }

    request = GetIntoTeachingApiClient::ExistingCandidateRequest.new(identity_data)
    api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
    api.exchange_access_token_for_schools_experience_sign_up(code, request)
  rescue GetIntoTeachingApiClient::ApiError
    errors.add(:code, :invalid)
    nil
  end

private

  def matchback_attributes
    {
      email: email,
      firstName: firstname,
      lastName: lastname,
      dateOfBirth: date_of_birth,
    }
  end
end
