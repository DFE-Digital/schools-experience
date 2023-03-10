class GetIntoTeachingApiClient::CandidatesApi
  def create_candidate_access_token(request)
    raise GetIntoTeachingApiClient::ApiError if request.email =~ /unknown/
  end
end

class GetIntoTeachingApiClient::PrivacyPoliciesApi
  def get_latest_privacy_policy
    GetIntoTeachingApiClient::PrivacyPolicy.new(id: SecureRandom.uuid, text: "policy")
  end

  def get_privacy_policy(id)
    GetIntoTeachingApiClient::PrivacyPolicy.new(id: id, text: "policy")
  end
end

class GetIntoTeachingApiClient::LookupItemsApi
  def get_teaching_subjects
    [
      GetIntoTeachingApiClient::TeachingSubject.new(id: SecureRandom.uuid, value: "Maths")
    ]
  end
end

class GetIntoTeachingApiClient::SchoolsExperienceApi
  KNOWN_UUID = "b8dd28e3-7bed-4cc2-9602-f6ee725344d2".freeze

  def add_school_experience(_id, _candidate_school_experience); end

  def exchange_access_token_for_schools_experience_sign_up(_code, request)
    GetIntoTeachingApiClient::SchoolsExperienceSignUp.new(fake_sign_up_data).tap do |sign_up|
      sign_up.email = request.email
      sign_up.first_name = request.first_name
      sign_up.last_name = request.last_name
    end
  end

  def get_schools_experience_sign_ups(ids)
    ids.map do |id|
      GetIntoTeachingApiClient::SchoolsExperienceSignUp.new(fake_sign_up_data).tap do |sign_up|
        sign_up.candidate_id = id
      end
    end
  end

  def get_schools_experience_sign_up(id)
    GetIntoTeachingApiClient::SchoolsExperienceSignUp.new(fake_sign_up_data).tap do |sign_up|
      sign_up.candidate_id = id
    end
  end

  def sign_up_schools_experience_candidate(sign_up)
    sign_up.candidate_id = fake_candidate_id
    sign_up
  end

private

  def fake_candidate_id
    SecureRandom.uuid
  end

  def fake_sign_up_data
    {
      candidate_id: fake_candidate_id,
      first_name: 'Matthew',
      last_name: 'Richards',
      full_name: 'Matthew Richards',
      telephone: '01234 567890',
      email: 'first@thisaddress.com',
      address_line1: 'First Line',
      address_line2: 'Second Line',
      address_line3: 'Third Line',
      address_city: 'Manchester',
      address_state_or_province: 'Manchester',
      address_postcode: 'TE57 1NG',
      merged: false
    }
  end
end
