shared_context "when the API candidate matches back" do
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to \
      receive(:create_candidate_access_token)
  end
end

shared_context "when the API candidate does not match back" do
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to \
      receive(:create_candidate_access_token)
        .and_raise(GetIntoTeachingApiClient::ApiError)
  end
end

shared_context "when the API returns an incorrect verification code" do
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:exchange_access_token_for_schools_experience_sign_up)
      .and_raise(GetIntoTeachingApiClient::ApiError)
  end
end

shared_context "when the API is healthy" do
  before do
    response = GetIntoTeachingApiClient::HealthCheckResponse.new(status: "healthy", crm: "ok")
    allow_any_instance_of(GetIntoTeachingApiClient::OperationsApi).to \
      receive(:health_check) { response }
  end
end

shared_context "when the API cannot be reached" do
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::OperationsApi).to \
      receive(:health_check).and_raise(GetIntoTeachingApiClient::ApiError)
  end
end

shared_context "when the API is degraded but CRM is online" do
  before do
    response = GetIntoTeachingApiClient::HealthCheckResponse.new(status: "degraded", crm: "ok")
    allow_any_instance_of(GetIntoTeachingApiClient::OperationsApi).to \
      receive(:health_check) { response }
  end
end

shared_context "when the API returns a correct verification code" do
  let(:code) { "123456" }
  let(:sign_up) { build(:api_schools_experience_sign_up_with_name) }

  before do
    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:exchange_access_token_for_schools_experience_sign_up)
      .with(code, an_instance_of(GetIntoTeachingApiClient::ExistingCandidateRequest)) { sign_up }
  end
end

shared_context "when the API returns a correct verification code for personal information" do
  let(:code) { "123456" }
  let(:request) do
    GetIntoTeachingApiClient::ExistingCandidateRequest.new(
      first_name: personal_info.first_name,
      last_name: personal_info.last_name,
      email: personal_info.email
    )
  end
  let(:sign_up) { build(:api_schools_experience_sign_up_with_name) }

  before do
    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:exchange_access_token_for_schools_experience_sign_up)
      .with(code, request) { sign_up }
  end
end

shared_context "when the API returns a correct verification code for personal information without a name" do
  let(:code) { "123456" }
  let(:request) do
    GetIntoTeachingApiClient::ExistingCandidateRequest.new(
      first_name: personal_info.first_name,
      last_name: personal_info.last_name,
      email: personal_info.email
    )
  end
  let(:sign_up) { build(:api_schools_experience_sign_up) }

  before do
    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:exchange_access_token_for_schools_experience_sign_up)
      .with(code, request) { sign_up }
  end
end

shared_context "when the API returns the latest privacy policy" do
  let(:current_policy) { build(:api_privacy_policy) }

  before do
    allow_any_instance_of(GetIntoTeachingApiClient::PrivacyPoliciesApi).to \
      receive(:get_latest_privacy_policy) { current_policy }
  end
end

shared_context "when the API returns teaching subjects" do
  let(:teaching_subjects) { [] }

  before do
    allow_any_instance_of(GetIntoTeachingApiClient::LookupItemsApi).to \
      receive(:get_teaching_subjects) { teaching_subjects }
  end
end

shared_context "when the API signs up" do
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:sign_up_schools_experience_candidate)
        .with(an_instance_of(GetIntoTeachingApiClient::SchoolsExperienceSignUp)) do
          build(:api_schools_experience_sign_up_with_name)
        end
  end
end

shared_context "when the API adds school experience" do
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:add_school_experience)
       .with(anything, an_instance_of(GetIntoTeachingApiClient::CandidateSchoolExperience))
  end
end

shared_context "when the API signs up for requests" do
  let(:ids) { requests.map(&:contact_uuid) }
  let(:sign_ups) do
    ids.map { |id| build(:api_schools_experience_sign_up_with_name, candidate_id: id) }
  end

  before do
    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:get_schools_experience_sign_ups)
        .with(a_collection_containing_exactly(*ids)) { sign_ups }
  end
end

shared_context "when the API signs up for the first request" do
  before do
    id = requests.first.contact_uuid

    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:get_schools_experience_sign_up)
        .with(id) { build(:api_schools_experience_sign_up_with_name, candidate_id: id) }
  end
end
