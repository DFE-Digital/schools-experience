class Healthcheck
  include GitisAccess

  delegate :to_json, to: :to_h

  FUNCTIONAL_API_STATUS_CODES = %w[healthy degraded].freeze

  def deployment
    ENV.fetch('DEPLOYMENT_ID') { 'not set' }
  end

  def app_sha
    read_file "/etc/school-experience-sha"
  end

  def test_redis
    return nil unless ENV["REDIS_URL"]

    REDIS.ping == "PONG"
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
    health = GetIntoTeachingApiClient::OperationsApi.new.health_check

    FUNCTIONAL_API_STATUS_CODES.any?(health.status)
  rescue Faraday::Error, GetIntoTeachingApiClient::ApiError
    false
  end

  def test_dfe_signin_api
    res = Schools::DFESignInAPI::Organisations.new(SecureRandom.uuid).uuids

    ActiveModel::Type::Boolean.new.cast(res)
  rescue RuntimeError, Rack::Timeout::RequestTimeoutException
    false
  end

  def to_h
    dfe_auth = test_dfe_signin_api
    gitis_api = test_gitis
    db = test_postgresql
    redis = test_redis

    is_healthy = dfe_auth && gitis_api && db && redis

    {
      deployment_id: deployment,
      app_sha: app_sha,
      dfe_auth: dfe_auth,
      gitis_api: gitis_api,
      db: db,
      cache: redis,
      healthy: is_healthy,
      status: is_healthy ? 'OK' : 'FAILING',
    }
  end

private

  def read_file(file)
    File.read(file).strip
  rescue Errno::ENOENT
    nil
  end
end
