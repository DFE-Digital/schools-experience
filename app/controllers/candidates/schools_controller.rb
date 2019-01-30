class Candidates::SchoolsController < ApplicationController
  def index
    @search = Candidates::SchoolSearch.new(search_params)
  end

  def show
    @school = OpenStruct.new(YAML.load_file('demo-school.yml'))
  end

private

  def search_params
    params.permit(:query, :location, :distance, :max_fee, phases: [], subjects: [])
  end
end
