class Candidates::SessionsController < Candidates::DashboardBaseController
  include GitisAccess
  skip_before_action :authenticate_user!

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
    token = Candidates::SessionToken.valid.find_by(token: params[:authtoken])
    return unless token

    self.current_candidate = token.candidate
    token.invalidate_other_tokens
    redirect_to candidates_dashboard_path
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
