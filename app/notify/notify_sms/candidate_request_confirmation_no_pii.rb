class NotifySms::CandidateRequestConfirmationNoPii < NotifyDespatchers::NotifySms
  attr_accessor \
    :school_name

  def initialize(
    to:,
    school_name:
  )

    self.school_name = school_name

    super(to: to)
  end

private

  def template_id
    '880be18e-fbd4-4427-8b87-59e026626031'
  end

  def personalisation
    {
      school_name: school_name
    }
  end
end
