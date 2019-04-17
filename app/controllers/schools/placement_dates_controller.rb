class Schools::PlacementDatesController < Schools::BaseController
  def index
    @placement_dates = current_school.school_profile.placement_dates.future
  end

  def create
  end

  def destroy
  end
end
