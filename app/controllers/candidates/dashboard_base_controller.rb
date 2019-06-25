module Candidates
  class DashboardBaseController < ApplicationController
    include GitisAuthentication
    before_action :authenticate_user!
  end
end
