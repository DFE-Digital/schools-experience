shared_context "enable git_api feature" do
  around do |example|
    Flipper.enable(:git_api)
    example.run
    Flipper.disable(:git_api)
  end
end

shared_context "api candidate matched back" do
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to \
      receive(:create_candidate_access_token)
  end
end

shared_context "api candidate not matched back" do
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to \
      receive(:create_candidate_access_token)
        .and_raise(GetIntoTeachingApiClient::ApiError)
  end
end

shared_context "api incorrect verification code" do
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:exchange_access_token_for_schools_experience_sign_up)
      .and_raise(GetIntoTeachingApiClient::ApiError)
  end
end

shared_context "api correct verification code" do
  let(:code) { "123456" }
  let(:sign_up) { build(:api_schools_experience_sign_up) }

  before do
    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:exchange_access_token_for_schools_experience_sign_up)
      .with(code, an_instance_of(GetIntoTeachingApiClient::ExistingCandidateRequest)) { sign_up }
  end
end

shared_context "api correct verification code for personal info" do
  let(:code) { "123456" }
  let(:request) do
    GetIntoTeachingApiClient::ExistingCandidateRequest.new(
      firstName: personal_info.first_name,
      lastName: personal_info.last_name,
      email: personal_info.email,
      dateOfBirth: personal_info.date_of_birth
    )
  end
  let(:sign_up) { build(:api_schools_experience_sign_up) }

  before do
    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:exchange_access_token_for_schools_experience_sign_up)
      .with(code, request) { sign_up }
  end
end

shared_context "api latest privacy policy" do
  let(:latest_policy) { build(:api_privacy_policy) }

  before do
    allow_any_instance_of(GetIntoTeachingApiClient::PrivacyPoliciesApi).to \
      receive(:get_latest_privacy_policy) { latest_policy }
  end
end

shared_context "api teaching subjects" do
  let(:teaching_subjects) { [] }

  before do
    allow_any_instance_of(GetIntoTeachingApiClient::LookupItemsApi).to \
      receive(:get_teaching_subjects) { teaching_subjects }
  end
end

shared_context "api sign up" do
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:sign_up_schools_experience_candidate)
        .with(an_instance_of(GetIntoTeachingApiClient::SchoolsExperienceSignUp)) do
          build(:api_schools_experience_sign_up)
        end
  end
end

shared_context "api add classroom experience note" do
  before do
    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:add_classroom_experience_note)
        .with(anything, an_instance_of(GetIntoTeachingApiClient::ClassroomExperienceNote))
  end
end

shared_context "api sign ups for requests" do
  let(:ids) { requests.map(&:contact_uuid) }
  let(:sign_ups) do
    ids.map { |id| build(:api_schools_experience_sign_up, candidate_id: id) }
  end

  before do
    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:get_schools_experience_sign_ups)
        .with(a_collection_containing_exactly(*ids)) { sign_ups }
  end
end

shared_context "api sign up for first request" do
  before do
    id = requests.first.contact_uuid

    allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
      receive(:get_schools_experience_sign_up)
        .with(id) { build(:api_schools_experience_sign_up, candidate_id: id) }
  end
end
