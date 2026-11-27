shared_context "with a stubbed API client" do
  let(:stubbed_api_clients) { {} }

  def stubbed_api_client(api_class)
    stubbed_api_clients[api_class] ||= begin
      api_client = instance_double(api_class)
      allow(api_class).to receive(:new).and_return(api_client)
      api_client
    end
  end
end

shared_context "when the API candidate matches back" do
  include_context "with a stubbed API client"

  before do
    api_client = stubbed_api_client(GetIntoTeachingApiClient::CandidatesApi)
    allow(api_client).to receive(:create_candidate_access_token)
  end
end

shared_context "when the API candidate does not match back" do
  include_context "with a stubbed API client"

  before do
    api_client = stubbed_api_client(GetIntoTeachingApiClient::CandidatesApi)
    allow(api_client).to receive(:create_candidate_access_token)
        .and_raise(GetIntoTeachingApiClient::ApiError)
  end
end

shared_context "when the API returns an incorrect verification code" do
  include_context "with a stubbed API client"

  before do
    api_client = stubbed_api_client(GetIntoTeachingApiClient::SchoolsExperienceApi)
    allow(api_client).to receive(:exchange_access_token_for_schools_experience_sign_up)
      .and_raise(GetIntoTeachingApiClient::ApiError)
  end
end

shared_context "when the API is healthy" do
  include_context "with a stubbed API client"

  before do
    response = GetIntoTeachingApiClient::HealthCheckResponse.new(status: "healthy", crm: "ok")
    api_client = stubbed_api_client(GetIntoTeachingApiClient::OperationsApi)
    allow(api_client).to receive(:health_check) { response }
  end
end

shared_context "when the API cannot be reached" do
  include_context "with a stubbed API client"

  before do
    api_client = stubbed_api_client(GetIntoTeachingApiClient::OperationsApi)
    allow(api_client).to receive(:health_check).and_raise(GetIntoTeachingApiClient::ApiError)
  end
end

shared_context "when the API is degraded but CRM is online" do
  include_context "with a stubbed API client"

  before do
    response = GetIntoTeachingApiClient::HealthCheckResponse.new(status: "degraded", crm: "ok")
    api_client = stubbed_api_client(GetIntoTeachingApiClient::OperationsApi)
    allow(api_client).to receive(:health_check) { response }
  end
end

shared_context "when the API returns a correct verification code" do
  include_context "with a stubbed API client"

  let(:code) { "123456" }
  let(:sign_up) { build(:api_schools_experience_sign_up_with_name) }

  before do
    api_client = stubbed_api_client(GetIntoTeachingApiClient::SchoolsExperienceApi)
    allow(api_client).to receive(:exchange_access_token_for_schools_experience_sign_up)
      .with(code, an_instance_of(GetIntoTeachingApiClient::ExistingCandidateRequest)) { sign_up }
  end
end

shared_context "when the API returns a correct verification code for personal information" do
  include_context "with a stubbed API client"

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
    api_client = stubbed_api_client(GetIntoTeachingApiClient::SchoolsExperienceApi)
    allow(api_client).to receive(:exchange_access_token_for_schools_experience_sign_up)
      .with(code, request) { sign_up }
  end
end

shared_context "when the API returns a correct verification code for personal information without a name" do
  include_context "with a stubbed API client"

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
    api_client = stubbed_api_client(GetIntoTeachingApiClient::SchoolsExperienceApi)
    allow(api_client).to receive(:exchange_access_token_for_schools_experience_sign_up)
      .with(code, request) { sign_up }
  end
end

shared_context "when the API returns the latest privacy policy" do
  include_context "with a stubbed API client"

  let(:current_policy) { build(:api_privacy_policy) }

  before do
    api_client = stubbed_api_client(GetIntoTeachingApiClient::PrivacyPoliciesApi)
    allow(api_client).to receive(:get_latest_privacy_policy) { current_policy }
  end
end

shared_context "when the API returns teaching subjects" do
  include_context "with a stubbed API client"

  let(:teaching_subjects) { [] }

  before do
    api_client = stubbed_api_client(GetIntoTeachingApiClient::LookupItemsApi)
    allow(api_client).to receive(:get_teaching_subjects) { teaching_subjects }
  end
end

shared_context "when the API signs up" do
  include_context "with a stubbed API client"

  before do
    api_client = stubbed_api_client(GetIntoTeachingApiClient::SchoolsExperienceApi)
    allow(api_client).to receive(:sign_up_schools_experience_candidate)
        .with(an_instance_of(GetIntoTeachingApiClient::SchoolsExperienceSignUp)) do
          build(:api_schools_experience_sign_up_with_name)
        end
  end
end

shared_context "when the API adds school experience" do
  include_context "with a stubbed API client"

  before do
    api_client = stubbed_api_client(GetIntoTeachingApiClient::SchoolsExperienceApi)
    allow(api_client).to receive(:add_school_experience)
       .with(anything, an_instance_of(GetIntoTeachingApiClient::CandidateSchoolExperience))
  end
end

shared_context "when the API signs up for requests" do
  include_context "with a stubbed API client"

  let(:ids) { requests.map(&:contact_uuid) }
  let(:sign_ups) do
    ids.map { |id| build(:api_schools_experience_sign_up_with_name, candidate_id: id) }
  end

  before do
    api_client = stubbed_api_client(GetIntoTeachingApiClient::SchoolsExperienceApi)
    allow(api_client).to receive(:get_schools_experience_sign_ups)
        .with(a_collection_containing_exactly(*ids)) { sign_ups }
  end
end

shared_context "when the API signs up for the first request" do
  include_context "with a stubbed API client"

  before do
    id = requests.first.contact_uuid

    api_client = stubbed_api_client(GetIntoTeachingApiClient::SchoolsExperienceApi)
    allow(api_client).to receive(:get_schools_experience_sign_up)
        .with(id) { build(:api_schools_experience_sign_up_with_name, candidate_id: id) }
  end
end
