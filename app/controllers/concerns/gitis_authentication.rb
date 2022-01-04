module GitisAuthentication
  extend ActiveSupport::Concern
  include GitisAccess

  class UnauthorizedCandidate < RuntimeError; end

  class UnconfirmedCandidate < RuntimeError; end

  class InvalidContact < RuntimeError; end

  included do
    rescue_from UnauthorizedCandidate, with: -> { redirect_to candidates_signin_path }
  end

protected

  def current_contact
    return nil unless session[:gitis_contact]

    GetIntoTeachingApiClient::SchoolsExperienceSignUp.build_from_hash(session[:gitis_contact])
  end

  def current_contact=(contact)
    raise InvalidContact unless contact.is_a?(GetIntoTeachingApiClient::SchoolsExperienceSignUp)

    if current_contact && current_contact.candidate_id != contact.candidate_id
      Rails.logger.warn "Signed in Candidate overwritten - #{current_contact.candidate_id} to #{contact.candidate_id}"
      delete_registration_sessions!
    end

    contact.tap do |c|
      session[:gitis_contact] = c.to_hash
    end
  end

  def current_candidate
    return nil unless current_contact

    @current_candidate ||=
      Bookings::Candidate.confirmed.find_by_gitis_contact(current_contact)
  end

  def candidate_signed_in?
    !current_candidate.nil?
  end

  def current_candidate=(candidate)
    raise UnconfirmedCandidate unless candidate.confirmed?

    self.current_contact = candidate.gitis_contact ||
      assign_gitis_contact(candidate).gitis_contact

    @current_candidate = candidate
  end

  def authenticate_user!
    current_candidate || raise(UnauthorizedCandidate)
  end

  def delete_registration_sessions!
    session[:registrations] = nil
  end
end
