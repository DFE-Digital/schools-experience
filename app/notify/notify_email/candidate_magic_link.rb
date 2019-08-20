class NotifyEmail::CandidateMagicLink < Notify
  attr_accessor :school_name, :confirmation_link

  def self.template_id
    'a06fe38a-5f7f-4c68-8612-6aae9495a8ab'
  end

  def initialize(to:, school_name:, confirmation_link:)
    self.school_name = school_name
    self.confirmation_link = confirmation_link
    super(to: to)
  end

private

  def template_id
    self.class.template_id
  end

  def personalisation
    { school_name: school_name, confirmation_link: confirmation_link }
  end
end
