module GitisAuthentication
  extend ActiveSupport::Concern
  extend GitisAccess

  class UnauthorizedCandidate < RuntimeError; end
  class InvalidContact < RuntimeError; end

  included do
    rescue_from UnauthorizedCandidate, with: -> { redirect_to candidates_signin_path }
  end

protected

  def current_contact
    return nil unless session[:gitis_contact]

    @current_contact ||= Bookings::Gitis::Contact.new(session[:gitis_contact])
  end

  def current_contact=(contact)
    raise InvalidContact unless contact.is_a?(Bookings::Gitis::Contact)

    contact.tap do |c|
      session[:gitis_contact] = c.attributes
    end
  end

  def current_candidate
    return nil unless current_contact

    @current_candidate ||=
      Bookings::Candidate.find_by!(gitis_uuid: current_contact.id)
  end

  def current_candidate=(candidate)
    self.current_contact = gitis_crm.find(candidate.gitis_uuid)
    @current_candidate = candidate
  end

  def authenticate_user!
    current_candidate || fail(UnauthorizedCandidate)
  end
end
