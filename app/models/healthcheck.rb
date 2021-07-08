class Healthcheck
  include GitisAccess

  delegate :to_json, to: :to_h

  FUNCTIONAL_API_STATUS_CODES = %w[healthy degraded].freeze
  HEALTHY_CRM_STATUS_CODE = "ok".freeze

  def deployment
    ENV.fetch('DEPLOYMENT_ID') { 'not set' }
  end

  def app_sha
    read_file "/etc/school-experience-sha"
  end

  def test_redis
    return nil unless ENV["REDIS_URL"]

    Redis.current.ping == "PONG"
  rescue RuntimeError, Errno::ETIMEDOUT
    false
  end

  def test_postgresql
    ApplicationRecord.connection
    ApplicationRecord.connected?
  rescue RuntimeError
    false
  end

  def test_gitis
    if Flipper.enabled?(:git_api)
      api_gitis_check
    else
      direct_gitis_check
    end
  end

  def test_dfe_signin_api
    !Schools::DFESignInAPI::Organisations.new(SecureRandom.uuid).uuids.nil?
  rescue RuntimeError, Rack::Timeout::RequestTimeoutException
    false
  end

  def to_h
    dfe_auth = test_dfe_signin_api
    api = test_gitis
    db = test_postgresql
    redis = test_redis

    is_healthy = dfe_auth && api && db && redis

    {
      deployment_id: deployment,
      app_sha: app_sha,
      dfe_auth: dfe_auth,
      api: api,
      db: db,
      cache: redis,
      healthy: is_healthy,
      status: is_healthy ? 'OK' : 'FAILING',
    }
  end

private

  def api_gitis_check
    health = GetIntoTeachingApiClient::OperationsApi.new.health_check

    FUNCTIONAL_API_STATUS_CODES.any?(health.status) &&
      health.crm == HEALTHY_CRM_STATUS_CODE
  rescue Faraday::Error, GetIntoTeachingApiClient::ApiError
    false
  end

  def direct_gitis_check
    gitis_crm.fetch(Bookings::Gitis::Country, limit: 1)

    true
  rescue RuntimeError
    false
  end

  def read_file(file)
    File.read(file).strip
  rescue Errno::ENOENT
    nil
  end
end
