class Candidates::SchoolsController < ApplicationController
  def index
    @search = Candidates::School.new(search_params)
  end

  def show

  end

private

  def search_params
    params.permit(*Candidates::School.attributes_registry.keys)
  end

end
