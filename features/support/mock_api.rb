KNOWN_UUID = "b8dd28e3-7bed-4cc2-9602-f6ee725344d2".freeze

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
    dateOfBirth: '1980-01-01'
  }
end

Before do
  allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
    receive(:add_classroom_experience_note)
      .with(anything, an_instance_of(GetIntoTeachingApiClient::ClassroomExperienceNote))

  allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to \
    receive(:create_candidate_access_token) do |_, req|
      raise GetIntoTeachingApiClient::ApiError if req.email =~ /unknown/
    end

  allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
    receive(:exchange_access_token_for_schools_experience_sign_up) do |_, req|
      GetIntoTeachingApiClient::SchoolsExperienceSignUp.new(fake_sign_up_data).tap do |sign_up|
        sign_up.email = req.email
        sign_up.first_name = req.first_name
        sign_up.last_name = req.last_name
        sign_up.date_of_birth = req.date_of_birth
      end
    end

  allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
    receive(:get_schools_experience_sign_ups) do |_, ids|
      ids.map do |id|
        GetIntoTeachingApiClient::SchoolsExperienceSignUp.new(fake_sign_up_data).tap do |sign_up|
          sign_up.candidate_id = id
        end
      end
    end
end
