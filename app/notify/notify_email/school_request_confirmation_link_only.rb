class NotifyEmail::SchoolRequestConfirmationLinkOnly < Notify
  attr_accessor :school_name, :placement_request_url

  def initialize(to:, school_name:, placement_request_url:)
    self.school_name = school_name
    self.placement_request_url = placement_request_url
    super(to: to)
  end

private

  def template_id
    '2a5a54b8-17cb-4da8-94ce-1647d6bf1da3'
  end

  def personalisation
    {
      school_name: school_name,
      placement_request_url: placement_request_url
    }
  end
end
