class Candidates::SessionsController < ApplicationController
  include GitisAuthentication

  def new
    @candidates_session = Candidates::Session.new(gitis_crm)
  end

  def create
    @candidates_session = Candidates::Session.new(gitis_crm, retrieve_params)
    @verification_code = Candidates::VerificationCode.new(retrieve_params)

    if @candidates_session.valid?
      @verification_code.issue_verification_code
    else
      render 'new'
    end
  end

  def update
    @verification_code = Candidates::VerificationCode.new(retrieve_params)
    candidate_data = @verification_code.exchange

    if candidate_data
      self.current_candidate = Bookings::Candidate.find_or_create_from_gitis_contact!(candidate_data).tap do |c|
        c.update(confirmed_at: Time.zone.now)
      end
      redirect_to candidates_dashboard_path
    else
      render :create
    end
  end

private

  def retrieve_params
    if params.key?(:candidates_session)
      session_params
    else
      verification_code_params
    end
  end

  def verification_code_params
    params.require(:candidates_verification_code).permit(:code, :email, :firstname, :lastname, :date_of_birth)
  end

  def session_params
    params.require(:candidates_session).permit(:email, :firstname, :lastname, :date_of_birth)
  end

  def deliver_signin_link(email_address, token)
    NotifyEmail::CandidateSigninLink.new(
      to: email_address,
      confirmation_link: candidates_signin_confirmation_url(token)
    ).despatch_later!
  end
end
