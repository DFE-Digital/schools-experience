class ServiceUpdatesController < ApplicationController
  def index
    @service_updates = ServiceUpdate.latest(10)
  end
end
