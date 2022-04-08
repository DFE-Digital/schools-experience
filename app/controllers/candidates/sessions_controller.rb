class Candidates::SessionsController < ApplicationController
  include GitisAuthentication
  helper_method :try_matchback_again?

  def new
    @candidates_session = Candidates::Session.new
  end

  def create
    @candidates_session = Candidates::Session.new(retrieve_params)
    @verification_code = Candidates::VerificationCode.new(retrieve_params)

    render 'new' unless @candidates_session.valid?

    unless @verification_code.issue_verification_code
      matchback_failures[:number_of_failures] += 1
      render "matchback_failed"
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

  def sign_out
    sign_candidate_out

    redirect_to candidates_dashboard_path
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
    params.require(:candidates_verification_code).permit(:code, :email, :firstname, :lastname)
  end

  def session_params
    params.require(:candidates_session).permit(:email, :firstname, :lastname)
  end

  def try_matchback_again?
    matchback_failures[:number_of_failures] < 3
  end

  def matchback_failures
    session["matchback_failures"] ||= {
      number_of_failures: 0
    }
  end
end
