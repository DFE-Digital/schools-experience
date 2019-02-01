class Candidate::Registrations::AccountChecksController < Candidate::RegistrationsController
  def new
    @account_check = Candidate::Registrations::AccountCheck.new
  end

  def create
    @account_check = Candidate::Registrations::AccountCheck.new account_check_params
    if @account_check.valid?
      current_registration[:account_check] = @account_check.attributes
      redirect_to new_candidate_registrations_personal_detail_path
    else
      render :new
    end
  end

private

  def account_check_params
    params.require(:candidate_registrations_account_check).permit \
      :full_name,
      :email
  end
end
