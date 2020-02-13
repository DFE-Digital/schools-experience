class ServiceUpdatesController < ApplicationController
  def show
    @service_updates = ServiceUpdate.latest(10)
  end
end
