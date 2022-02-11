class FeatureFlagsController < ApplicationController
  def index
    @environments = Feature.all_environments
    @features = Feature.all
  end
end
