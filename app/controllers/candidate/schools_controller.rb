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
    return {} unless params[:candidate_school]
    params.require(:candidate_school).permit(*Candidate::School.attributes_registry.keys)
  end

end
