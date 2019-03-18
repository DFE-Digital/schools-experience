class RenameBookingsSchoolSearchesResultsToNumberOfResults < ActiveRecord::Migration[5.2]
  def change
    rename_column :bookings_school_searches, :results, :number_of_results
  end
end
