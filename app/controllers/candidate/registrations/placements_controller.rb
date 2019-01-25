class Candidate::Registrations::PlacementsController < ApplicationController
  def new
    @placement = Candidate::Registrations::Placement.new
  end

  def create
    @placement = Candidate::Registrations::Placement.new placement_params
    if @placement.valid?
      persist! @placement
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

  def persist!(placement)
    #registration = Registraion.new(session[:registration])
    #registration.placement = placement
    session[:registration] = { placement: placement.attributes }
  end
end
