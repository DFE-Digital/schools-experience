class Candidate::SchoolsController < ApplicationController
  def index
    @search = Candidate::School.new(search_params)

    if @search.filtering_results?
      render :search_results
    end
  end

  def show

  end

private

  def search_params
    params.permit(*Candidate::School.attributes_registry.keys)
  end

end
