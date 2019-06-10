class Candidates::Session
  attr_reader :contact, :candidate

  def initialize(gitis)
    @gitis = gitis
  end

  def login(attrs)
    return false unless lookup_contact_in_gitis(attrs)

    find_or_create_candidate
    generate_session_token
    email_token_to_client

    candidate
  end

private

  def lookup_contact_in_gitis(email:, firstname:, lastname:, date_of_birth:)
    contact = @gitis.find_contact_for_signin(
      email: email,
      firstname: firstname,
      lastname: lastname,
      date_of_birth: date_of_birth
    )

    if contact
      @contact = contact
    else
      false
    end
  end

  def find_or_create_candidate
    @candidate = Bookings::Candidate.find_or_create_by(gitis_uuid: contact.id)
  end

  def generate_session_token
    @candidate.session_tokens.create!
  end

  def email_token_to_client
    # FIXME to be done
  end
end
