class Candidate::Registrations::PlacementsController < Candidate::RegistrationsController
  def new
    @placement = Candidate::Registrations::Placement.new
  end

  def create
    @placement = Candidate::Registrations::Placement.new placement_params
    if @placement.valid?
      current_registration[:placement] = @placement.attributes
      redirect_to new_candidate_registrations_personal_detail_path
    else
      render :new
    end
  end

private

  def placement_params
    params.require(:candidate_registrations_placement).permit \
      :date_start,
      :date_end,
      :objectives,
      :access_needs,
      :access_needs_details
  end
end
