class Candidates::SchoolsController < ApplicationController
  def index
    @search = Candidates::School.new(search_params)
  end

  def show
    # Shut linter up
  end

private

  def search_params
    params.permit(:query, :distance, :fees, phase: [], subject: [])
  end
end
