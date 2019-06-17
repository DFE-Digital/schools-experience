class Candidates::SessionsController < ApplicationController
  include GitisAuthentication

  def new
    @candidates_session = Candidates::Session.new(gitis_crm)
  end

  def create
    @candidates_session = Candidates::Session.new(gitis_crm, session_params)

    if @candidates_session.valid?
      token = @candidates_session.create_signin_token
      return unless token

      deliver_signin_link(@candidates_session.email, token)
    else
      render 'new'
    end
  end

  def update
    candidate = Candidates::Session.signin!(params[:authtoken])

    if candidate
      self.current_candidate = candidate
      redirect_to candidates_dashboard_path
    end
  end

private

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
