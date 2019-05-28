class AddTrackingUuidToBookingsSchoolSearches < ActiveRecord::Migration[5.2]
  def change
    # no indexes, these won't be used by the app
    add_column :bookings_school_searches, :analytics_tracking_uuid, :uuid, null: true
    add_column :bookings_placement_requests, :analytics_tracking_uuid, :uuid, null: true
  end
end
