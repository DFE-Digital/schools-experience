class Candidate::Registrations::PersonalDetailsController < Candidate::RegistrationsController
  def new
    @personal_details = Candidate::Registrations::PersonalDetail.new
  end

  def create
    @personal_details = Candidate::Registrations::PersonalDetail.new personal_detail_params
    if @personal_details.valid?
      current_registration[:personal_details] = @personal_details.attributes
      redirect_to new_candidate_registrations_account_info_path
    else
      render :new
    end
  end

private

  def personal_detail_params
    params.require(:candidate_registrations_personal_detail).permit \
      :building,
      :street,
      :town_or_city,
      :county,
      :postcode,
      :phone
  end
end
