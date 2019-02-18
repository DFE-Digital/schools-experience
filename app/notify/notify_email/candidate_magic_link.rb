class NotifyEmail::CandidateMagicLink < Notify
  attr_accessor :school_name, :confirmation_link

  def initialize(to:, school_name:, confirmation_link:)
    self.school_name = school_name
    self.confirmation_link = confirmation_link
    super(to: to)
  end

private

  def template_id
    '74dc6510-c89d-4b5b-9608-075d3f2de32d'
  end

  def personalisation
    { school_name: school_name, confirmation_link: confirmation_link }
  end
end
