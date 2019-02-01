class Candidates::SchoolsController < ApplicationController
  def index
    @search = Candidates::SchoolSearch.new(search_params)
  end

  def show
    # Shut linter up
  end

private

  def search_params
    params.permit(:query, :distance, :max_fee, phases: [], subjects: [])
  end
end
