class HealthchecksController < ApplicationController
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
end
