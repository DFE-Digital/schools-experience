class HealthchecksController < ApplicationController
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
end
