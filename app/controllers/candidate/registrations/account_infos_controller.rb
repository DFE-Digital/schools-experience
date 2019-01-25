class Candidate::Registrations::AccountInfosController < Candidate::RegistrationsController
  def new
    @account_info = Candidate::Registrations::AccountInfo.new
  end

  def create
    @account_info = Candidate::Registrations::AccountInfo.new account_info_params
    if @account_info.valid?
      current_registration[:account_info] = @account_info.attributes
      redirect_to new_candidate_registrations_background_and_security_check_path
    else
      render :new
    end
  end

private

  def account_info_params
    params.require(:candidate_registrations_account_info).permit \
      :degree_stage,
      :degree_stage_explaination,
      :degree_subject,
      :teaching_stage,
      :subject_first_choice,
      :subject_second_choice
  end
end
