require 'rails_helper'

# This is an independent test suite which formalises my adhoc tests against the
# GiTiS CRM system. It does not make use of the abstractions in the application
# to ensure its only testing the API against our understanding of how it should
# behave

RSpec.describe "The GITIS CRM Api" do
  before(:each) { WebMock.disable! }
  after(:each) { WebMock.enable! }

  let(:access_token) { retrieve_access_token }

  it "can read Contacts from the CRM", :read do
    # Read the first contact
    resp = crm_get("/contacts", "$top" => "3")

    expect(resp.status).to eql(200)
    expect(resp.headers).to include('content-type' => 'application/json; odata.metadata=minimal')

    data = JSON.parse(resp.body)
    expect(data['value'].length).to eql(3)
    firstcontact = data['value'][0]
    expect(firstcontact['contactid']).not_to be_blank

    # Read a single contact by Id
    resp = crm_get("/contacts(#{firstcontact['contactid']})")

    expect(resp.status).to eql(200)
    expect(resp.headers).to include('content-type' => 'application/json; odata.metadata=minimal')

    contact = JSON.parse(resp.body)
    expect(contact['contactid']).to eql(firstcontact['contactid'])

    # Read multiple contacts in a single query
    resp = crm_get("/contacts?$top=30&$filter=contactid eq '#{data['value'][0]['contactid']}' or contactid eq '#{data['value'][1]['contactid']}' or contactid eq '#{data['value'][2]['contactid']}'")
    contacts = JSON.parse(resp.body)

    expect(contacts['value'].length).to eql(3)
    expect(contacts['value'].pluck('contactid')).to eql(data['value'].pluck('contactid'))
  end

  it "can read Countries from the CRM", :read do
    resp = crm_get('/dfe_countries', '$top' => 50)

    expect(resp.status).to eql(200)
    expect(resp.headers).to include('content-type' => 'application/json; odata.metadata=minimal')

    data = JSON.parse(resp.body)
    expect(data['value'].length).to eql(50)
  end

  it "can read Teaching Subjects from the CRM", :read do
    resp = crm_get('/dfe_teachingsubjectlists', '$top' => 10)

    expect(resp.status).to eql(200)
    expect(resp.headers).to include('content-type' => 'application/json; odata.metadata=minimal')

    data = JSON.parse(resp.body)
    expect(data['value'].length).to eql(10)
  end

  it "can read Qualifications from the CRM", :read do
    resp = crm_get('/dfe_candidatequalifications', '$top' => 10)

    expect(resp.status).to eql(200)
    expect(resp.headers).to include('content-type' => 'application/json; odata.metadata=minimal')

    data = JSON.parse(resp.body)
    expect(data['value'].length).to be > 1
  end

  it "can read PrivacyPolices from the CRM", :read do
    resp = crm_get('/dfe_privacypolicies', '$top' => 10)

    expect(resp.status).to eql(200)
    expect(resp.headers).to include('content-type' => 'application/json; odata.metadata=minimal')

    data = JSON.parse(resp.body)
    expect(data['value'].length).to be > 1
  end

  it "can write to the CRM", :write do
    # Create a new contact
    resp = crm_post('/contacts', new_contact_data)

    expect(resp.status).to eql(204)
    expect(resp.headers['odata-entityid']).not_to be_nil

    contact_url = resp.headers['odata-entityid']
    expect(contact_url).to match(%r{#{service_url}#{endpoint}/contacts\([a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}\)})

    contact_id = contact_url.gsub(%r{#{service_url}#{endpoint}/contacts\(([a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12})\)}, '\1')

    # Read Contact Back
    resp = crm_get("/contacts(#{contact_id})?$expand=dfe_Country")
    expect(resp.status).to eql(200)

    data = JSON.parse(resp.body)
    expect(data).to include('contactid' => contact_id)
    expect(data).to include('firstname' => new_contact_data['firstname'])
    expect(data).to include('lastname' => new_contact_data['lastname'])
    expect(data['dfe_Country']).to include('dfe_name' => 'United Kingdom')

    # Update the newly created contact
    resp = crm_patch("/contacts(#{contact_id})", update_contact_data(data))
    expect(resp.status).to eql(204)

    # Read Contact Back
    resp = crm_get("/contacts(#{contact_id})")
    expect(resp.status).to eql(200)

    data = JSON.parse(resp.body)
    expect(data).to include('contactid' => contact_id)
    expect(data).to include('firstname' => new_contact_data['firstname'])
    expect(data).to include('lastname' => "New Last Name")

    # Create School Experience
    resp = crm_post('/dfe_candidateschoolexperiences', {
      'dfe_notes' => 'test suite'
    })
    expect(resp.status).to eql(204)
    expect(resp.headers['odata-entityid']).not_to be_nil

    experience_url = resp.headers['odata-entityid']
    expect(experience_url).to match(%r{#{service_url}#{endpoint}/dfe_candidateschoolexperiences\([a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}\)})
    experience_id = experience_url.gsub(%r{#{service_url}#{endpoint}/dfe_candidateschoolexperiences\(([a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12})\)}, '\1')

    # Read School Experience Back
    resp = crm_get("/dfe_candidateschoolexperiences(#{experience_id})")
    expect(resp.status).to eql(200)

    data = JSON.parse(resp.body)
    expect(data).to include('dfe_candidateschoolexperienceid' => experience_id)
    expect(data).to include('dfe_notes' => "test suite")

    # Update School Experience
    resp = crm_patch("/dfe_candidateschoolexperiences(#{experience_id})", {
      "dfe_notes" => "First Line\r\n\r\nSecond Line"
    })
    expect(resp.status).to eql(204)

    resp = crm_get("/dfe_candidateschoolexperiences(#{experience_id})")
    expect(resp.status).to eql(200)

    data = JSON.parse(resp.body)
    expect(data).to include('dfe_candidateschoolexperienceid' => experience_id)
    expect(data).to include('dfe_notes' => "First Line\r\n\r\nSecond Line")

    resp = crm_post("/contacts(#{contact_id})/dfe_contact_dfe_candidateschoolexperience_ContactId/$ref", {
      "@odata.id" => "#{service_url}#{endpoint}/dfe_candidateschoolexperiences(#{experience_id})"
    })
    expect(resp.status).to eql(204)

    resp = crm_get("/contacts(#{contact_id})?$expand=dfe_contact_dfe_candidateschoolexperience_ContactId")
    expect(resp.status).to eql(200)

    data = JSON.parse(resp.body)
    expect(data).to include('contactid' => contact_id)
    expect(data).to include('firstname' => new_contact_data['firstname'])

    contact_se_data = data['dfe_contact_dfe_candidateschoolexperience_ContactId'][0]
    expect(contact_se_data).to include('dfe_candidateschoolexperienceid' => experience_id)
    expect(contact_se_data).to include('dfe_notes' => "First Line\r\n\r\nSecond Line")
  end

  it "can update existing Contacts in the CRM", :update do
    resp = crm_get("/contacts", "$top" => "1", "$filter" => " dfe_channelcreation ne null and dfe_channelcreation ne #{ENV.fetch('CRM_CHANNEL_CREATION')}")
    expect(resp.status).to eql(200)
    expect(resp.headers).to include('content-type' => 'application/json; odata.metadata=minimal')

    data = JSON.parse(resp.body)
    expect(data['value'].length).to eql(1)
    contact = data['value'][0]

    contact_id = contact['contactid']
    currenttime = Time.zone.now.strftime("%H:%I %d/%m/%Y")

    resp = crm_patch("/contacts(#{contact_id})", {
      'lastname' => "Updated by School Experience at #{currenttime}"
    })
    expect(resp.status).to eql(204)

    # Read Contact Back
    resp = crm_get("/contacts(#{contact_id})")
    expect(resp.status).to eql(200)

    data = JSON.parse(resp.body)
    expect(data).to include('contactid' => contact_id)
    expect(data).to include('lastname' => "Updated by School Experience at #{currenttime}")
  end

  private

  def retrieve_access_token
    params = {
      "grant_type" => "client_credentials",
      "scope" => "",
      "client_id" => client_id,
      "client_secret" => client_secret,
      "resource" => service_url,
    }

    conn = Faraday.new(auth_url)
    resp = conn.post do |req|
      req.url "/#{auth_tenant_id}/oauth2/token"
      req.headers['Accept'] = 'application/json'
      req.body = params.to_query
    end

    token_data = JSON.parse(resp.body)
    token_data['access_token']
  end

  def crm_get(url, params = nil)
    combined = "#{endpoint}#{url}"
    combined += "?#{params.to_query}" if params

    conn = Faraday.new(service_url)
    resp = conn.get do |req|
      req.headers['Accept'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers["OData-MaxVersion"] = "4.0"
      req.headers["OData-Version"] = "4.0"

      req.url combined
    end
  end

  def crm_post(url, params)
    conn = Faraday.new(service_url)
    resp = conn.post do |req|
      req.headers['Accept'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers["OData-MaxVersion"] = "4.0"
      req.headers["OData-Version"] = "4.0"
      req.headers["Content-Type"] = "application/json"

      req.url "#{endpoint}#{url}"
      req.body = params.to_json
    end
  end

  def crm_put(url, params)
    conn = Faraday.new(service_url)
    resp = conn.put do |req|
      req.headers['Accept'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers["OData-MaxVersion"] = "4.0"
      req.headers["OData-Version"] = "4.0"
      req.headers["Content-Type"] = "application/json"

      req.url "#{endpoint}#{url}"
      req.body = params.to_json
    end
  end

  def crm_patch(url, params)
    conn = Faraday.new(service_url)
    resp = conn.patch do |req|
      req.headers['Accept'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers["OData-MaxVersion"] = "4.0"
      req.headers["OData-Version"] = "4.0"
      req.headers["Content-Type"] = "application/json"

      req.url "#{endpoint}#{url}"
      req.body = params.to_json
    end
  end

  def auth_url
    "https://login.microsoftonline.com"
  end

  def service_url
    ENV.fetch('CRM_SERVICE_URL')
  end

  def client_id
    ENV.fetch('CRM_CLIENT_ID')
  end

  def client_secret
    ENV.fetch('CRM_CLIENT_SECRET')
  end

  def auth_tenant_id
    ENV.fetch('CRM_AUTH_TENANT_ID')
  end

  def endpoint
    "/api/data/v9.1"
  end

  def new_contact_data
    countryid = ENV.fetch('CRM_COUNTRY_ID')

    {
      'firstname' => "Test User",
      'lastname' => "TestUser",
      'emailaddress2' => "school-experience-testuser@education.gov.uk",
      'telephone2' => "01234567890",
      'address1_line1' => "First Address Line",
      'address1_line2' => "Second Address Line",
      'address1_line3' => "Third Address Line",
      'address1_city' => "Manchester",
      'address1_stateorprovince' => "",
      'address1_postalcode' => "MA1 1AM",
      'statecode' => 0,
      'dfe_channelcreation' => ENV.fetch('CRM_CHANNEL_CREATION'),
      'dfe_notesforclassroomexperience' => "Written by School Experience",
      'dfe_hasdbscertificate' => true,
      'dfe_dateofissueofdbscertificate' => Date.today.to_s(:db),
      'dfe_Country@odata.bind' => "dfe_countries(#{countryid})" # UK
#      'ownerid' => ENV.fetch('CRM_OWNER_ID')
    }
  end

  def update_contact_data(existing_data)
    {
      'lastname' => 'New Last Name',
      'dfe_hasdbscertificate' => false,
      'dfe_dateofissueofdbscertificate' => nil,
      'dfe_notesforclassroomexperience' =>
        existing_data['dfe_notesforclassroomexperience'] +
        "#{existing_data['dfe_notesforclassroomexperience']}\nUpdated at #{Time.zone.now}"
    }
  end

end
