class GetIntoTeachingApiClient::SchoolsExperienceApi
  def add_classroom_experience_note(id, note); end
end

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

class GetIntoTeachingApiClient::SchoolsExperienceApi
  KNOWN_UUID = "b8dd28e3-7bed-4cc2-9602-f6ee725344d2".freeze

  def exchange_access_token_for_schools_experience_sign_up(_code, request)
    GetIntoTeachingApiClient::SchoolsExperienceSignUp.new(fake_sign_up_data).tap do |sign_up|
      sign_up.email = request.email
      sign_up.first_name = request.first_name
      sign_up.last_name = request.last_name
      sign_up.date_of_birth = request.date_of_birth
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
    fake_uuid = Rails.application.config.x.gitis.fake_crm_uuid

    if %w[true yes 1].include? fake_uuid
      KNOWN_UUID
    else
      fake_uuid.presence || SecureRandom.uuid
    end
  end

  def fake_sign_up_data
    {
      candidateId: fake_candidate_id,
      firstName: 'Matthew',
      lastName: 'Richards',
      mobileTelephone: '07123 456789',
      telephone: '01234 567890',
      email: 'first@thisaddress.com',
      secondaryEmail: 'second@thisaddress.com',
      addressLine1: 'First Line',
      addressLine2: 'Second Line',
      addressLine3: 'Third Line',
      addressCity: 'Manchester',
      addressStateOrProvince: 'Manchester',
      addressPostcode: 'TE57 1NG',
      addressTelephone: '01234 567890',
      dateOfBirth: '1980-01-01',
      merged: false
    }
  end
end
