class Healthcheck
  include GitisAccess

  delegate :to_json, to: :to_h

  def deployment
    ENV.fetch('DEPLOYMENT_ID') { 'not set' }
  end

  def app_sha
    read_file "/etc/get-teacher-training-adviser-service-sha"
  end

  def test_redis
    return nil unless ENV["REDIS_URL"]

    Redis.current.ping == "PONG"
  rescue RuntimeError
    false
  end

  def test_postgresql
    ApplicationRecord.connection
    ApplicationRecord.connected?
  rescue RuntimeError
    false
  end

  def test_gitis
    gitis_crm.fetch(Bookings::Gitis::Country, limit: 1)

    true
  rescue RuntimeError
    false
  end

  def test_dfe_signin_api
    return true unless Schools::DFESignInAPI::Organisations.enabled?

    Schools::DFESignInAPI::Organisations.new(SecureRandom.uuid).uuids
  rescue RuntimeError
    false
  end

  def to_h
    auth = test_dfe_signin_api
    api = test_gitis
    db = test_postgresql
    redis = test_redis

    is_healthy = auth && api && db && redis

    {
      deployment_id: deployment,
      app_sha: app_sha,
      auth: auth,
      api: api,
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
