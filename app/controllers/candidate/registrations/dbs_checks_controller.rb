class Candidate::Registrations::DbsChecksController < Candidate::RegistrationsController
  def new
    @dbs_check = Candidate::Registrations::DbsCheck.new
  end

  def create
    @dbs_check = Candidate::Registrations::DbsCheck.new dbs_check_params
    if @dbs_check.valid?
      current_registration[:dbs_check] = @dbs_check.attributes
      redirect_to candidate_registrations_placement_request_path
    else
      render :new
    end
  end

private

  def dbs_check_params
    params.require(:candidate_registrations_dbs_check).permit :has_dbs_check
  end
end
