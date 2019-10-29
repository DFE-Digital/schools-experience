class RemoveBookingsPlacementDatesSubjectsFromBookingsPlacementRequests < ActiveRecord::Migration[5.2]
  require_relative '20191015152254_add_bookings_placement_dates_subject_id_to_bookings_placement_requests'

  def change
    revert AddBookingsPlacementDatesSubjectIdToBookingsPlacementRequests
  end
end
