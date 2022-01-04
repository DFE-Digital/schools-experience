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

    request = GetIntoTeachingApiClient::ExistingCandidateRequest.new(matchback_attributes)
    api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
    existing_sign_up = api.exchange_access_token_for_schools_experience_sign_up(code, request)

    existing_sign_up.tap do |info|
      info.first_name = firstname if info.first_name.blank? && firstname.present?
      info.last_name = lastname if info.last_name.blank? && lastname.present?
    end
  rescue GetIntoTeachingApiClient::ApiError
    errors.add(:code, :invalid)
    nil
  end

private

  def matchback_attributes
    {
      email: email,
      first_name: firstname,
      last_name: lastname
    }
  end
end
