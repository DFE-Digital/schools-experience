module Apimock
  class GitisCrm
    attr_reader :client_id, :client_secret, :auth_tenant_id, :service_url

    def initialize(client_id, client_secret, auth_tenant_id, service_url)
      @client_id = client_id
      @client_secret = client_secret
      @auth_tenant_id = auth_tenant_id
      @service_url = service_url
    end

    def stub_contact_request(uuid, return_params = {})
      stub_request(:get, "#{service_url}#{endpoint}/contacts(#{uuid})?$top=1").
        with(headers: get_headers).
        to_return(
          status: 200,
          headers: {
            'Content-Type' => 'application/json; odata.metadata=minimal',
          },
          body: contact_data.merge(
            '@odata.context' => "#{service_url}#{endpoint}/$metadata#contacts/$entity",
            'contactid' => uuid
          ).merge(return_params.stringify_keys).to_json
        )
    end

    def stub_multiple_contact_request(uuids, return_params = {})
      uuidfilter = uuids.map { |id| "contactid eq '#{id}'" }.join(' or ')

      stub_request(:get, "#{service_url}#{endpoint}/contacts?$top=#{uuids.length}&$filter=#{uuidfilter}").
        with(headers: get_headers).
        to_return(
          status: 200,
          headers: {
            'Content-Type' => 'application/json; odata.metadata=minimal',
          },
          body: {
            '@odata.context' => "#{service_url}#{endpoint}/$metadata#contacts/$entity",
            'value' => uuids.map { |uuid|
              contact_data.merge('contactid' => uuid).
                merge(return_params.stringify_keys)
            }
          }.to_json
        )
    end

    def stub_contact_request_by_email(email, return_params = {})
      stub_request(:get, "#{service_url}#{endpoint}/contacts?$top=1&$filter=emailaddress1 eq '#{email}' or emailaddress2 eq '#{email}' or emailaddress3 eq '#{email}'").
        with(headers: get_headers).
        to_return(
          status: 200,
          headers: {
            'Content-Type' => 'application/json; odata.metadata=minimal',
          },
          body: {
            '@odata.context' => "#{service_url}#{endpoint}/$metadata#contacts/$entity",
            'value' => [
              contact_data.merge('emailaddress1' => email). \
                merge(return_params.stringify_keys)
            ]
          }.to_json
        )
    end

    def stub_contact_listing_request(uuid = SecureRandom.uuid)
      stub_request(:get, "#{service_url}#{endpoint}/contacts?$top=3").
        with(headers: get_headers).
        to_return(
          status: 200,
          headers: {
            'Content-Type' => 'application/json; odata.metadata=minimal',
          },
          body: {
            "@odata.context" => "#{service_url}#{endpoint}/$metadata#contacts",
            "value" => [contact_data.merge('contactid' => uuid)]
          }.to_json
        )
    end

    def stub_access_token(id: client_id, secret: client_secret)
      stub_request(:post, "#{auth_url}/#{auth_tenant_id}/oauth2/token").
        with(
          headers: { 'Accept' => 'application/json' },
          body: {
            "grant_type" => "client_credentials",
            "scope" => "",
            "client_id" => id,
            "client_secret" => secret,
            "resource" => service_url,
          }.to_query
        ).
        to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: {
            'token_type' => 'Bearer',
            'expires_in' => 3600,
            'resource' => service_url,
            'access_token' => "MY.STUB.TOKEN"
          }.to_json
        )
    end

    def stub_invalid_access_token(id: client_id, secret: 'invalid')
      stub_request(:post, "#{auth_url}/#{auth_tenant_id}/oauth2/token").
        with(
          headers: { 'Accept' => 'application/json' },
          body: {
            "grant_type" => "client_credentials",
            "scope" => "",
            "client_id" => id,
            "client_secret" => secret,
            "resource" => service_url,
          }.to_query
        ).
        to_return(
          status: 401,
          headers: { 'Content-Type' => 'application/json' },
          body: {
            "error" => "invalid_client",
            "error_description" => "AADSTS7000215: Invalid client secret is provided."
          }.to_json
        )
    end

    def stub_create_contact_request(params, return_uuid = SecureRandom.uuid)
      stub_request(:post, "#{service_url}#{endpoint}/contacts").
        with(headers: post_headers, body: params.stringify_keys.to_json).
        to_return(
          status: 204,
          headers: {
            'content-type' => 'application/json',
            'odata-entityid' => "#{service_url}#{endpoint}/contacts(#{return_uuid})"
          },
          body: ''
        )
    end

    def stub_update_contact_request(params, uuid)
      stub_request(:patch, "#{service_url}#{endpoint}/contacts(#{uuid})").
        with(headers: post_headers, body: params.to_json).
        to_return(
          status: 204,
          headers: {
            'content-type' => 'application/json',
            'odata-entityid' => "#{service_url}#{endpoint}/contacts(#{uuid})"
          },
          body: ''
        )
    end

    def stub_create_school_experience_request(params)
      stub_request(:post, "#{service_url}#{endpoint}/dfe_candidateschoolexperiences").
        with(headers: post_headers, body: params.to_json).
        to_return(
          status: 204,
          headers: {
            'content-type' => 'application/json',
            'odata-entityid' => "#{service_url}#{endpoint}/dfe_candidateschoolexperiences(#{SecureRandom.uuid})"
          },
          body: ''
        )
    end

    def stub_school_experience_request(uuid, params = {})
      stub_request(:get, "#{service_url}#{endpoint}/dfe_candidateschoolexperiences(#{uuid})").
        with(headers: get_headers).
        to_return(
          status: 200,
          headers: {
            'Content-Type' => 'application/json; odata.metadata=minimal',
          },
          body: {
            '@odata.context' => "#{service_url}#{endpoint}/$metadata#contacts/$entity",
            'dfe_candidateschoolexperienceid' => uuid,
            'dfe_notes' => 'test suite'
          }.merge(params.stringify_keys).to_json
        )
    end

    def stub_update_school_experience_request(uuid, params)
      stub_request(:patch, "#{service_url}#{endpoint}/dfe_candidateschoolexperiences(#{uuid})").
        with(headers: post_headers, body: params.to_json).
        to_return(
          status: 204,
          headers: { 'content-type' => 'application/json' },
          body: ''
        )
    end

    def stub_attach_school_experience_request(contact_id, experience_id)
      stub_request(:post, "#{service_url}#{endpoint}/contacts(#{contact_id})/dfe_contact_dfe_candidateschoolexperience_ContactId/$ref").
        with(headers: post_headers, body: {
          "@odata.id" => "#{service_url}#{endpoint}/dfe_candidateschoolexperiences(#{experience_id})"
        }.to_json).
        to_return(
          status: 204,
          headers: { 'content-type' => 'application/json' },
          body: ''
        )
    end

    def stub_expanded_contact_request(contact_id, experience_id, contact_params = {}, experience_params = {})
      stub_request(:get, "#{service_url}#{endpoint}/contacts(#{contact_id})?$expand=dfe_contact_dfe_candidateschoolexperience_ContactId").
        with(headers: get_headers).
        to_return(
          status: 200,
          headers: {
            'Content-Type' => 'application/json; odata.metadata=minimal',
          },
          body: {
            '@odata.context' => "#{service_url}#{endpoint}/$metadata#contacts/$entity",
            'contactid' => contact_id,
            'firstname' => 'first name',
            'lastname' => 'last name',
            'dfe_contact_dfe_candidateschoolexperience_ContactId' => [
              {
                'dfe_candidateschoolexperienceid' => experience_id,
                'dfe_notes' => 'Some notes'
              }.merge(experience_params.stringify_keys)
            ]
          }.merge(contact_params.stringify_keys).to_json
        )
    end

  private

    def stub_request(method, uri)
      WebMock::StubRegistry.instance.
        register_request_stub(WebMock::RequestStub.new(method, uri))
    end

    def auth_url
      "https://login.microsoftonline.com"
    end

    def endpoint
      "/api/data/v9.1"
    end

    def get_headers
      {
        'Accept' => 'application/json',
        'Authorization' => /\ABearer \w+\.\w+\.\w+\z/,
        "OData-MaxVersion" => "4.0",
        "OData-Version" => "4.0",
      }
    end

    def post_headers
      {
        'Accept' => 'application/json',
        'Authorization' => /\ABearer \w+\.\w+\.\w+\z/,
        "OData-MaxVersion" => "4.0",
        "OData-Version" => "4.0",
        "Content-Type" => "application/json"
      }
    end

    def contact_data
      {
        'firstname' => "Test User",
        'lastname' => "TestUser",
        'emailaddress1' => "school-experience-testuser@education.gov.uk",
        'mobilephone' => "07123456789",
        'telephone1' => "01234567890",
        'address1_line1' => "First Address Line",
        'address1_line2' => "Second Address Line",
        'address1_line3' => "Third Address Line",
        'address1_city' => "Manchester",
        'address1_stateorprovince' => "",
        'address1_postalcode' => "MA1 1AM",
        'statecode' => 0,
        'dfe_channelcreation' => 222750021
      }
    end
  end
end
