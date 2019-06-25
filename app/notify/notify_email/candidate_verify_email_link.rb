class NotifyEmail::CandidateVerifyEmailLink < Notify
  attr_accessor :verification_link

  def initialize(to:, verification_link:)
    self.verification_link = verification_link
    super(to: to)
  end

private

  def template_id
    '0e4b2eaa-ae1f-472a-9293-c2a24f3f8187'
  end

  def personalisation
    { verification_link: verification_link }
  end
end
