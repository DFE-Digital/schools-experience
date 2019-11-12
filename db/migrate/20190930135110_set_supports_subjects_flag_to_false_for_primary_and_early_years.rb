class SetSupportsSubjectsFlagToFalseForPrimaryAndEarlyYears < ActiveRecord::Migration[5.2]
  def up
    Bookings::Phase.where(name: ['Early years', 'Primary (4 to 11)']).update_all(supports_subjects: false)
  end

  def down
    # true is the default
    Bookings::Phase.update_all(supports_subjects: true)
  end
end
