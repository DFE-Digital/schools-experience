class AddDisabilityConfidentToBookingsSchoolSearch < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings_school_searches, :disability_confident, :boolean
  end
end
