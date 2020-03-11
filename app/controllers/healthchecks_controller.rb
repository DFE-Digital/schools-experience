class HealthchecksController < ApplicationController
  include GitisAccess

  http_basic_authenticate_with \
    name: Rails.application.config.x.healthchecks.username,
    password: Rails.application.config.x.healthchecks.password,
    except: :show

  def show
    unless Redis.current.ping == 'PONG'
      raise "No Redis Connection"
    end

    ApplicationRecord.connection
    unless ApplicationRecord.connected?
      raise "No Database Connection"
    end

    render plain: 'healthy'
  end

  def deployment
    render plain: ENV.fetch('DEPLOYMENT_ID') { 'not set' }
  end

  def api_health
    check_gitis_api
    check_dfe_signin_api

    render plain: 'healthy'
  end

private

  def check_gitis_api
    gitis_crm.fetch(Bookings::Gitis::Country, limit: 1)
  end

  def check_dfe_signin_api
    return true unless Schools::DFESignInAPI::Organisations.enabled?

    Schools::DFESignInAPI::Organisations.new(SecureRandom.uuid).uuids
  end
end
