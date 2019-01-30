class Candidates::SchoolsController < ApplicationController
  def index
    @search = Candidates::SchoolSearch.new(search_params)
  end

  def show
    @school = OpenStruct.new(
      name: "A school",
      postcode: "MA1 1AM"
    )
  end

private

  def search_params
    params.permit(:query, :location, :distance, :max_fee, phases: [], subjects: [])
  end
end
