class NotifyEmail::CandidateSigninLink < Notify
  attr_accessor :confirmation_link

  def initialize(to:, confirmation_link:)
    self.confirmation_link = confirmation_link
    super(to: to)
  end

private

  def template_id
    '5b451894-3640-47df-a119-6461ecb890d9'
  end

  def personalisation
    { confirmation_link: confirmation_link }
  end
end
