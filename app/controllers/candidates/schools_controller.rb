class Candidates::SchoolsController < ApplicationController
  def index
    @search = Candidates::SchoolSearch.new(search_params)
  end

  def show
    @school = Candidates::SchoolStub.find(params[:id])
  end

private

  def search_params
    params.permit(:query, :location, :distance, :max_fee, :order, phases: [], subjects: [])
  end
end
