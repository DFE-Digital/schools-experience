class Candidates::SessionsController < ApplicationController
  include GitisAuthentication

  before_action :check_api_feature_enabled, only: %i[update create]

  def new
    @candidates_session = Candidates::Session.new(gitis_crm)
  end

  def create
    @candidates_session = Candidates::Session.new(gitis_crm, retrieve_params)
    @verification_code = Candidates::VerificationCode.new(retrieve_params)

    if @candidates_session.valid?
      if @git_api_enabled
        @verification_code.issue_verification_code
      else
        token = @candidates_session.create_signin_token
        return unless token

        deliver_signin_link(@candidates_session.email, token)
      end
    else
      render 'new'
    end
  end

  def update
    @git_api_enabled ? api_verify : direct_verify
  end

private

  def api_verify
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

  def direct_verify
    candidate = Candidates::Session.signin!(params[:authtoken])

    if candidate
      self.current_candidate = candidate
      redirect_to candidates_dashboard_path
    end
  end

  def check_api_feature_enabled
    @git_api_enabled = Flipper.enabled?(:git_api)
  end

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
