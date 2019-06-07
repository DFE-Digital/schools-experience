class Candidates::SessionsController < Candidates::DashboardBaseController
  include GitisAccess
  skip_before_action :authenticate_user!

  def new
    @candidates_session = Candidates::Session.new(gitis_crm)
  end

  def create
    @candidates_session = Candidates::Session.new(gitis_crm, session_params)

    if @candidates_session.valid?
      @candidates_session.signin
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
end
