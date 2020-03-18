namespace :gitis do
  desc "Retrieve the $metadata xml content from the configured Gitis source - outputs to STDOUT"
  task metadata: :environment do
    api = Bookings::Gitis::Factory.crm.send(:store).send(:api)
    token = api.access_token
    conn = api.send(:connection)

    response = conn.get do |c|
      c.url '$metadata'
      c.headers = {
        'Authorization' => "Bearer #{token}",
        'OData-MaxVersion' => '4.0',
        'OData-Version' => '4.0'
      }
    end

    puts response.body
  end
end
