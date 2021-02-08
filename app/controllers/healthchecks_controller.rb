class HealthchecksController < ApplicationController
  def deployment
    @healthcheck = Healthcheck.new
    status = @healthcheck.to_h[:healthy] ? :ok : :internal_server_error

    render plain: @healthcheck.deployment, status: status
  end

  def api_health
    @healthcheck = Healthcheck.new

    if @healthcheck.to_h[:healthy]
      render plain: 'healthy', status: :ok
    else
      render plain: 'unhealthy', status: :internal_server_error
    end
  end

  def show
    @healthcheck = Healthcheck.new
    status = @healthcheck.to_h[:healthy] ? :ok : :internal_server_error

    render json: @healthcheck.to_json, status: status
  end

  def urn_whitelist
    whitelist = ENV['CANDIDATE_URN_WHITELIST'].blank? ? [] : ENV['CANDIDATE_URN_WHITELIST'].to_s.strip.split(%r{[\s,]+}).map(&:to_i)

    render json: whitelist
  end
end
