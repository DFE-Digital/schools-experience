class ServiceUpdatesController < ApplicationController
  def index
    @recent_updates = ServiceUpdate.latest(6)
    @latest = @recent_updates.shift
  end
end
