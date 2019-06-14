class SchoolsController < ApplicationController
  before_action :redirect_to_dashboard,
    if: -> { current_user.present? }

  def show; end
end
